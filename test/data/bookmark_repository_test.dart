import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/error/app_exception.dart';
import 'package:vlau_assessment/data/datasources/local/hive_local_store.dart';
import 'package:vlau_assessment/data/datasources/remote/api_client.dart';
import 'package:vlau_assessment/data/models/outbox_mutation.dart';
import 'package:vlau_assessment/data/repositories/bookmark_repository_impl.dart';
import 'package:vlau_assessment/data/repositories/feed_repository_impl.dart';
import 'package:vlau_assessment/domain/services/article_update_bus.dart';

import '../helpers.dart';

void main() {
  late Directory tempDir;
  late HiveLocalStore store;
  late MockApi api;
  late FakeConnectivity connectivity;
  late ArticleUpdateBus bus;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('bookmarks_test');
    Hive.init(tempDir.path);
    store = await HiveLocalStore.open();
    api = MockApi();
    connectivity = FakeConnectivity();
    bus = ArticleUpdateBus();
    when(
      () => api.setBookmark(any(), bookmarked: any(named: 'bookmarked')),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await bus.dispose();
    await connectivity.dispose();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  BookmarkRepositoryImpl buildRepository() => BookmarkRepositoryImpl(
    api: api,
    store: store,
    connectivity: connectivity,
    bus: bus,
  );

  test(
    'a bookmark persists across app restarts (Hive close & reopen)',
    () async {
      await buildRepository().toggle(makeArticle('a1'));

      await Hive.close();
      Hive.init(tempDir.path);
      store = await HiveLocalStore.open();

      final restored = await buildRepository().bookmarks();
      expect(restored.map((a) => a.id), ['a1']);
      expect(restored.single.isBookmarked, isTrue);
    },
  );

  test('toggling off removes the persisted bookmark', () async {
    final repository = buildRepository();
    await repository.toggle(makeArticle('a1'));
    await repository.toggle(makeArticle('a1', isBookmarked: true));

    expect(await repository.bookmarks(), isEmpty);
    expect(await store.isBookmarked('a1'), isFalse);
  });

  test(
    'offline: bookmark is stored locally and queued in the outbox',
    () async {
      connectivity.setOnline(false);

      await buildRepository().toggle(makeArticle('a1'));

      expect(await store.isBookmarked('a1'), isTrue);
      final pending = await store.pendingMutations();
      expect(pending, hasLength(1));
      expect(pending.single.op, OutboxMutation.opSetBookmark);
      expect(pending.single.payload['bookmarked'], isTrue);
      verifyNever(
        () => api.setBookmark(any(), bookmarked: any(named: 'bookmarked')),
      );
    },
  );

  test('offline toggle on/off coalesces to a single outbox mutation', () async {
    connectivity.setOnline(false);
    final repository = buildRepository();

    await repository.toggle(makeArticle('a1'));
    await repository.toggle(makeArticle('a1', isBookmarked: true));

    final pending = await store.pendingMutations();
    expect(pending, hasLength(1));
    expect(pending.single.payload['bookmarked'], isFalse);
  });

  test(
    'a server failure falls back to the outbox, keeping local state',
    () async {
      when(
        () => api.setBookmark(any(), bookmarked: any(named: 'bookmarked')),
      ).thenThrow(const ServerException());

      await buildRepository().toggle(makeArticle('a1'));

      expect(await store.isBookmarked('a1'), isTrue);
      expect(await store.pendingMutations(), hasLength(1));
    },
  );

  test(
    'a feed load after restart keeps the bookmark on the feed item',
    () async {
      await buildRepository().toggle(makeArticle('a1'));

      await Hive.close();
      Hive.init(tempDir.path);
      store = await HiveLocalStore.open();

      // The server no longer remembers the bookmark (mock backend restarted,
      // or the flag simply is not part of the feed payload).
      when(() => api.getFeed(page: 1, topicId: null, source: null)).thenAnswer(
        (_) async => FeedPageResponse(
          items: [makeArticle('a1'), makeArticle('a2')],
          page: 1,
          total: 2,
        ),
      );

      final page = await FeedRepositoryImpl(
        api: api,
        store: store,
      ).firstPage();

      expect(page.items.firstWhere((a) => a.id == 'a1').isBookmarked, isTrue);
      expect(page.items.firstWhere((a) => a.id == 'a2').isBookmarked, isFalse);
      // The cache must not be clobbered either.
      expect((await store.article('a1'))!.isBookmarked, isTrue);
    },
  );

  test('a feed load reflects a bookmark removed locally', () async {
    final repository = buildRepository();
    await repository.toggle(makeArticle('a1'));
    await repository.toggle(makeArticle('a1', isBookmarked: true));

    when(() => api.getFeed(page: 1, topicId: null, source: null)).thenAnswer(
      (_) async => FeedPageResponse(
        // Server still echoes the bookmark it has not caught up on.
        items: [makeArticle('a1', isBookmarked: true)],
        page: 1,
        total: 1,
      ),
    );

    final page = await FeedRepositoryImpl(api: api, store: store).firstPage();

    expect(page.items.single.isBookmarked, isFalse);
  });
}
