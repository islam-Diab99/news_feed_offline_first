import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/error/app_exception.dart';
import 'package:vlau_assessment/data/datasources/remote/api_client.dart';
import 'package:vlau_assessment/data/models/outbox_mutation.dart';
import 'package:vlau_assessment/data/repositories/feed_repository_impl.dart';
import 'package:vlau_assessment/data/repositories/reaction_repository_impl.dart';
import 'package:vlau_assessment/data/services/outbox_sync_service.dart';
import 'package:vlau_assessment/domain/entities/article_update.dart';
import 'package:vlau_assessment/domain/services/article_update_bus.dart';

import '../helpers.dart';

void main() {
  late MockApi api;
  late InMemoryLocalStore store;
  late FakeConnectivity connectivity;
  late ArticleUpdateBus bus;
  late ReactionRepositoryImpl repository;

  final article = makeArticle('a1', likes: 10, isLiked: false, version: 3);

  setUpAll(() => registerFallbackValue(<OutboxMutation>[]));

  setUp(() {
    api = MockApi();
    store = InMemoryLocalStore();
    connectivity = FakeConnectivity();
    bus = ArticleUpdateBus();
    repository = ReactionRepositoryImpl(
      api: api,
      store: store,
      connectivity: connectivity,
      bus: bus,
    );
  });

  tearDown(() async {
    await bus.dispose();
    await connectivity.dispose();
  });

  void stubReaction(FutureOr<ReactionResponse> Function() respond) {
    when(
      () => api.setReaction(
        any(),
        liked: any(named: 'liked'),
        clientMutationId: any(named: 'clientMutationId'),
        expectedVersion: any(named: 'expectedVersion'),
      ),
    ).thenAnswer((_) async => respond());
  }

  test(
    'optimistic like is applied immediately, then confirmed by the server',
    () async {
      stubReaction(() => const ReactionSuccess(likes: 11, version: 4));
      final updates = <ArticleUpdate>[];
      final subscription = bus.stream.listen(updates.add);

      await repository.toggleLike(article);
      await Future<void>.delayed(Duration.zero);

      expect(updates, hasLength(2));
      final optimistic = (updates[0] as ArticleChanged).article;
      expect(optimistic.isLiked, isTrue);
      expect(optimistic.likes, 11);

      final confirmed = (updates[1] as ArticleChanged).article;
      expect(confirmed.version, 4);

      await subscription.cancel();
    },
  );

  test('rollback: a failed request reverts the optimistic state', () async {
    stubReaction(() => throw const ServerException('Reaction was not saved.'));
    final updates = <ArticleUpdate>[];
    final subscription = bus.stream.listen(updates.add);

    await expectLater(
      repository.toggleLike(article),
      throwsA(isA<ServerException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(updates, hasLength(2));
    final optimistic = (updates[0] as ArticleChanged).article;
    expect(optimistic.isLiked, isTrue);
    expect(optimistic.likes, 11);

    final rolledBack = (updates[1] as ArticleChanged).article;
    expect(rolledBack.isLiked, isFalse);
    expect(rolledBack.likes, 10);
    expect((await store.article('a1'))!.isLiked, isFalse);

    await subscription.cancel();
  });

  test('conflict: the server state wins over the optimistic guess', () async {
    stubReaction(
      () => const ReactionConflict(isLiked: true, likes: 186, version: 5),
    );
    final updates = <ArticleUpdate>[];
    final subscription = bus.stream.listen(updates.add);

    await repository.toggleLike(article);
    await Future<void>.delayed(Duration.zero);

    final reconciled = (updates.last as ArticleChanged).article;
    expect(reconciled.likes, 186);
    expect(reconciled.version, 5);

    await subscription.cancel();
  });

  test(
    'duplicate submissions are ignored while a request is in flight',
    () async {
      final gate = Completer<ReactionResponse>();
      when(
        () => api.setReaction(
          any(),
          liked: any(named: 'liked'),
          clientMutationId: any(named: 'clientMutationId'),
          expectedVersion: any(named: 'expectedVersion'),
        ),
      ).thenAnswer((_) => gate.future);

      final first = repository.toggleLike(article);
      final second = repository.toggleLike(article);

      gate.complete(const ReactionSuccess(likes: 11, version: 4));
      await Future.wait([first, second]);

      verify(
        () => api.setReaction(
          any(),
          liked: any(named: 'liked'),
          clientMutationId: any(named: 'clientMutationId'),
          expectedVersion: any(named: 'expectedVersion'),
        ),
      ).called(1);
    },
  );

  test('offline: optimistic state is kept and the mutation queued', () async {
    connectivity.setOnline(false);

    await repository.toggleLike(article);

    expect((await store.article('a1'))!.isLiked, isTrue);
    final pending = await store.pendingMutations();
    expect(pending, hasLength(1));
    expect(pending.single.op, OutboxMutation.opSetReaction);
    expect(pending.single.payload['reaction'], 'like');
    verifyNever(
      () => api.setReaction(
        any(),
        liked: any(named: 'liked'),
        clientMutationId: any(named: 'clientMutationId'),
        expectedVersion: any(named: 'expectedVersion'),
      ),
    );
  });

  test('offline like then unlike coalesces to the final intent only', () async {
    connectivity.setOnline(false);

    await repository.toggleLike(article);
    final liked = (await store.article('a1'))!;
    await repository.toggleLike(liked);

    final pending = await store.pendingMutations();
    expect(pending, hasLength(1));
    expect(pending.single.payload['reaction'], 'unlike');
  });

  test('a queued like survives a feed load that says otherwise', () async {
    connectivity.setOnline(false);
    await repository.toggleLike(article);

    // Back online, fresh launch: the server has no record of the like yet.
    connectivity.setOnline(true);
    when(() => api.getFeed(page: 1, topicId: null, source: null)).thenAnswer(
      (_) async => FeedPageResponse(
        items: [makeArticle('a1', likes: 10, isLiked: false)],
        page: 1,
        total: 1,
      ),
    );

    final page = await FeedRepositoryImpl(api: api, store: store).firstPage();

    expect(page.items.single.isLiked, isTrue);
    expect(page.items.single.likes, 11);
  });

  test('a settled sync republishes the article to the UI', () async {
    connectivity.setOnline(false);
    await repository.toggleLike(article);
    final queued = (await store.pendingMutations()).single;

    connectivity.setOnline(true);
    when(() => api.sync(any())).thenAnswer(
      (_) async => SyncResponse(applied: [queued.idempotencyKey]),
    );

    final updates = <ArticleUpdate>[];
    final subscription = bus.stream.listen(updates.add);
    final sync = OutboxSyncService(
      api: api,
      store: store,
      connectivity: connectivity,
      bus: bus,
    );

    await sync.syncNow();
    await Future<void>.delayed(Duration.zero);

    final published = updates.whereType<ArticleChanged>().last.article;
    expect(published.id, 'a1');
    expect(published.isLiked, isTrue);
    expect(published.likes, 11);
    expect(await store.pendingMutations(), isEmpty);

    await subscription.cancel();
    await sync.dispose();
  });
}
