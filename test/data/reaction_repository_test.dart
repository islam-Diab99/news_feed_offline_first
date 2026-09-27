import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/error/app_exception.dart';
import 'package:vlau_assessment/data/datasources/local/app_database.dart';
import 'package:vlau_assessment/data/datasources/remote/api_client.dart';
import 'package:vlau_assessment/data/models/outbox_mutation.dart';
import 'package:vlau_assessment/data/repositories/feed_repository_impl.dart';
import 'package:vlau_assessment/data/repositories/reaction_repository_impl.dart';
import 'package:vlau_assessment/data/services/outbox_sync_service.dart';
import 'package:vlau_assessment/domain/entities/article.dart';

import '../helpers.dart';

void main() {
  late MockApi api;
  late AppDatabase db;
  late FakeConnectivity connectivity;
  late ReactionRepositoryImpl repository;

  final article = makeArticle('a1', likes: 10, isLiked: false, version: 3);

  Future<Article> stored() async => (await db.articleDao.article('a1'))!;

  When<Future<ReactionResponse>> whenReaction() => when(
    () => api.setReaction(
      any(),
      liked: any(named: 'liked'),
      clientMutationId: any(named: 'clientMutationId'),
      expectedVersion: any(named: 'expectedVersion'),
    ),
  );

  setUpAll(() => registerFallbackValue(<OutboxMutation>[]));

  setUp(() async {
    api = MockApi();
    db = memoryDatabase();
    connectivity = FakeConnectivity();
    repository = ReactionRepositoryImpl(
      api: api,
      db: db,
      connectivity: connectivity,
    );
    await db.articleDao.saveServerArticles([article]);
  });

  tearDown(() async {
    await db.close();
    await connectivity.dispose();
  });

  test(
    'optimistic like shows before the server answers, then is confirmed',
    () async {
      final gate = Completer<ReactionResponse>();
      whenReaction().thenAnswer((_) => gate.future);

      final toggle = repository.toggleLike(article);
      await untilCalled(
        () => api.setReaction(
          any(),
          liked: any(named: 'liked'),
          clientMutationId: any(named: 'clientMutationId'),
          expectedVersion: any(named: 'expectedVersion'),
        ),
      );
      expect((await stored()).isLiked, isTrue);
      expect((await stored()).likes, 11);

      gate.complete(const ReactionSuccess(likes: 11, version: 4));
      await toggle;

      final confirmed = await stored();
      expect(confirmed.isLiked, isTrue);
      expect(confirmed.likes, 11);
      expect(confirmed.version, 4);
      expect(await db.outboxDao.pending(), isEmpty);
    },
  );

  test('rollback: a failed request reverts the optimistic state', () async {
    whenReaction().thenThrow(const ServerException('Reaction was not saved.'));

    await expectLater(
      repository.toggleLike(article),
      throwsA(isA<ServerException>()),
    );

    final rolledBack = await stored();
    expect(rolledBack.isLiked, isFalse);
    expect(rolledBack.likes, 10);
    expect(await db.outboxDao.pending(), isEmpty);
  });

  test('rollback restores an intent that was already queued', () async {
    connectivity.setOnline(false);
    await repository.toggleLike(article);

    connectivity.setOnline(true);
    whenReaction().thenThrow(const ServerException());
    await expectLater(
      repository.toggleLike(await stored()),
      throwsA(isA<ServerException>()),
    );

    expect((await stored()).isLiked, isTrue);
    final pending = await db.outboxDao.pending();
    expect(pending.single.value, isTrue);
  });

  test('conflict: the server state wins over the optimistic guess', () async {
    whenReaction().thenAnswer(
      (_) async =>
          const ReactionConflict(isLiked: true, likes: 186, version: 5),
    );

    await repository.toggleLike(article);

    final reconciled = await stored();
    expect(reconciled.isLiked, isTrue);
    expect(reconciled.likes, 186);
    expect(reconciled.version, 5);
  });

  test(
    'duplicate submissions are ignored while a request is in flight',
    () async {
      final gate = Completer<ReactionResponse>();
      whenReaction().thenAnswer((_) => gate.future);

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

    expect((await stored()).isLiked, isTrue);
    expect((await stored()).likes, 11);
    final pending = await db.outboxDao.pending();
    expect(pending.single.kind, MutationKind.reaction);
    expect(pending.single.value, isTrue);
    verifyNever(
      () => api.setReaction(
        any(),
        liked: any(named: 'liked'),
        clientMutationId: any(named: 'clientMutationId'),
        expectedVersion: any(named: 'expectedVersion'),
      ),
    );
  });

  test('a connection drop mid-request keeps the like queued', () async {
    whenReaction().thenThrow(const NetworkException());

    await repository.toggleLike(article);

    expect((await stored()).isLiked, isTrue);
    expect(await db.outboxDao.pending(), hasLength(1));
  });

  test('a queued like survives a feed load that says otherwise', () async {
    connectivity.setOnline(false);
    await repository.toggleLike(article);

    connectivity.setOnline(true);
    when(() => api.getFeed(page: 1, topicId: null, source: null)).thenAnswer(
      (_) async => FeedPageResponse(
        items: [makeArticle('a1', likes: 10, isLiked: false, version: 3)],
        page: 1,
        total: 1,
      ),
    );
    final feed = FeedRepositoryImpl(api: api, db: db);
    await feed.loadFirstPage();

    final item = (await feed.watchFeed().first).single;
    expect(item.isLiked, isTrue);
    expect(item.likes, 11);
  });

  group('outbox sync', () {
    late OutboxSyncService sync;

    setUp(() {
      sync = OutboxSyncService(api: api, db: db, connectivity: connectivity);
    });

    tearDown(() => sync.dispose());

    test('an applied reaction becomes the stored server state', () async {
      connectivity.setOnline(false);
      await repository.toggleLike(article);
      final queued = (await db.outboxDao.pending()).single;

      connectivity.setOnline(true);
      when(
        () => api.sync(any()),
      ).thenAnswer((_) async => SyncResponse(applied: [queued.idempotencyKey]));
      await sync.syncNow();

      expect(await db.outboxDao.pending(), isEmpty);
      final synced = await stored();
      expect(synced.isLiked, isTrue);
      expect(synced.likes, 11);
    });

    test('a conflicting reaction adopts the server article', () async {
      connectivity.setOnline(false);
      await repository.toggleLike(article);
      final queued = (await db.outboxDao.pending()).single;

      connectivity.setOnline(true);
      when(() => api.sync(any())).thenAnswer(
        (_) async => SyncResponse(
          applied: [queued.idempotencyKey],
          conflicts: [makeArticle('a1', likes: 40, isLiked: true, version: 6)],
        ),
      );
      await sync.syncNow();

      final synced = await stored();
      expect(synced.likes, 40);
      expect(synced.version, 6);
      expect(await db.outboxDao.pending(), isEmpty);
    });

    test('a toggle made while syncing is not lost', () async {
      connectivity.setOnline(false);
      await repository.toggleLike(article);
      final queued = (await db.outboxDao.pending()).single;

      connectivity.setOnline(true);
      when(() => api.sync(any())).thenAnswer((_) async {
        connectivity.setOnline(false);
        await repository.toggleLike(await stored());
        return SyncResponse(applied: [queued.idempotencyKey]);
      });
      await sync.syncNow();

      final pending = await db.outboxDao.pending();
      expect(pending.single.value, isFalse);
      expect((await stored()).isLiked, isFalse);
    });
  });
}
