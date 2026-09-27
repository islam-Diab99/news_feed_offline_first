import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/articles/data/local/app_database.dart';
import 'package:vlau_assessment/core/articles/data/remote/api_client.dart';
import 'package:vlau_assessment/core/articles/data/repositories/bookmark_repository_impl.dart';
import 'package:vlau_assessment/core/error/app_exception.dart';

import '../../helpers.dart';

void main() {
  late Directory tempDir;
  late AppDatabase db;
  late MockApi api;
  late FakeConnectivity connectivity;

  AppDatabase openDatabase() =>
      AppDatabase(NativeDatabase(File('${tempDir.path}/news.sqlite')));

  BookmarkRepositoryImpl buildRepository() =>
      bookmarkRepository(api, db, connectivity);

  Future<bool> isBookmarked(String id) async =>
      (await db.articlesDao.article(id))!.isBookmarked;

  void stubFeed(List<String> ids, {bool bookmarked = false}) {
    when(() => api.getFeed(page: 1, topicId: null, source: null)).thenAnswer(
      (_) async => FeedPageResponse(
        items: [
          for (final id in ids) makeArticle(id, isBookmarked: bookmarked),
        ],
        page: 1,
        total: ids.length,
      ),
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('bookmarks_test');
    db = openDatabase();
    api = MockApi();
    connectivity = FakeConnectivity();
    when(
      () => api.setBookmark(any(), bookmarked: any(named: 'bookmarked')),
    ).thenAnswer((_) async {});
    await db.articlesDao.saveServerArticles([makeArticle('a1')]);
  });

  tearDown(() async {
    await db.close();
    await connectivity.dispose();
    await tempDir.delete(recursive: true);
  });

  test('a bookmark persists across app restarts (close & reopen)', () async {
    await buildRepository().toggle(makeArticle('a1'));

    await db.close();
    db = openDatabase();

    final restored = await buildRepository().watchBookmarks().first;
    expect(restored.map((a) => a.id), ['a1']);
    expect(restored.single.isBookmarked, isTrue);
  });

  test('toggling off removes the bookmark', () async {
    final repository = buildRepository();
    await repository.toggle(makeArticle('a1'));
    await repository.toggle(makeArticle('a1', isBookmarked: true));

    expect(await repository.watchBookmarks().first, isEmpty);
    expect(await isBookmarked('a1'), isFalse);
  });

  test('online, a confirmed bookmark leaves nothing in the outbox', () async {
    await buildRepository().toggle(makeArticle('a1'));

    verify(() => api.setBookmark('a1', bookmarked: true)).called(1);
    expect(await db.outboxDao.pending(), isEmpty);
  });

  test('offline: stored locally and queued in the outbox', () async {
    connectivity.setOnline(false);

    await buildRepository().toggle(makeArticle('a1'));

    expect(await isBookmarked('a1'), isTrue);
    final pending = await db.outboxDao.pending();
    expect(pending.single.kind, MutationKind.bookmark);
    expect(pending.single.value, isTrue);
    verifyNever(
      () => api.setBookmark(any(), bookmarked: any(named: 'bookmarked')),
    );
  });

  test('offline toggles coalesce to the final intent', () async {
    connectivity.setOnline(false);
    final repository = buildRepository();

    await repository.toggle(makeArticle('a1'));
    await repository.toggle(makeArticle('a1', isBookmarked: true));

    final pending = await db.outboxDao.pending();
    expect(pending, hasLength(1));
    expect(pending.single.value, isFalse);
  });

  test('a server failure keeps the bookmark and queues it', () async {
    when(
      () => api.setBookmark(any(), bookmarked: any(named: 'bookmarked')),
    ).thenThrow(const ServerException());

    await buildRepository().toggle(makeArticle('a1'));

    expect(await isBookmarked('a1'), isTrue);
    expect(await db.outboxDao.pending(), hasLength(1));
  });

  test(
    'a feed load after restart keeps the bookmark the server forgot',
    () async {
      await buildRepository().toggle(makeArticle('a1'));
      await db.close();
      db = openDatabase();

      stubFeed(['a1', 'a2']);
      final feed = feedRepository(api, db);
      await feed.loadFirstPage();

      final items = await feed.watchFeed().first;
      expect(items.firstWhere((a) => a.id == 'a1').isBookmarked, isTrue);
      expect(items.firstWhere((a) => a.id == 'a2').isBookmarked, isFalse);
    },
  );

  test('a feed load cannot resurrect a bookmark removed locally', () async {
    final repository = buildRepository();
    await repository.toggle(makeArticle('a1'));
    await repository.toggle(makeArticle('a1', isBookmarked: true));

    stubFeed(['a1'], bookmarked: true);
    final feed = feedRepository(api, db);
    await feed.loadFirstPage();

    expect((await feed.watchFeed().first).single.isBookmarked, isFalse);
  });

  test(
    'a story removed by its publisher drops its bookmark and queued intents',
    () async {
      connectivity.setOnline(false);
      await buildRepository().toggle(makeArticle('a1'));

      await db.articlesDao.deleteArticles(['a1']);

      expect(await buildRepository().watchBookmarks().first, isEmpty);
      expect(await db.outboxDao.pending(), isEmpty);
    },
  );
}
