import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/articles/data/local/app_database.dart';
import 'package:vlau_assessment/core/articles/data/remote/api_client.dart';
import 'package:vlau_assessment/core/articles/domain/entities/article.dart';
import 'package:vlau_assessment/core/error/app_exception.dart';
import 'package:vlau_assessment/features/feed/data/feed_repository_impl.dart';
import 'package:vlau_assessment/features/feed/domain/feed_repository.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late MockApi api;
  late FeedRepositoryImpl repository;

  Article story(String id, int hour, {int likes = 10}) => makeArticle(
    id,
    likes: likes,
    publishedAt: DateTime.utc(2026, 9, 14, hour),
  );

  FeedPageResponse page(List<Article> items, {String? next}) =>
      FeedPageResponse(items: items, page: 1, total: 10, nextCursor: next);

  void stubPage(FeedPageResponse response, {String? cursor}) {
    when(
      () => cursor == null
          ? api.getFeed(page: 1, topicId: null, source: null)
          : api.getFeed(cursor: cursor, topicId: null, source: null),
    ).thenAnswer((_) async => response);
  }

  Future<List<String>> feedIds() async =>
      (await repository.watchFeed().first).map((a) => a.id).toList();

  setUpAll(() => registerFallbackValue(DateTime(2000)));

  setUp(() {
    db = memoryDatabase();
    api = MockApi();
    repository = feedRepository(api, db);
  });

  tearDown(() => db.close());

  test('pages append in publish order and never duplicate', () async {
    stubPage(page([story('a1', 9), story('a2', 8)], next: 'feed_2'));
    stubPage(page([story('a2', 8), story('a3', 7)]), cursor: 'feed_2');

    expect(
      await repository.loadFirstPage(),
      const FeedLoadResult(hasMore: true),
    );
    expect(
      await repository.loadNextPage(),
      const FeedLoadResult(hasMore: false),
    );

    expect(await feedIds(), ['a1', 'a2', 'a3']);
  });

  test('offline, the cached feed is served and flagged stale', () async {
    stubPage(page([story('a1', 9)], next: 'feed_2'));
    await repository.loadFirstPage();

    when(
      () => api.getFeed(page: 1, topicId: null, source: null),
    ).thenThrow(const NetworkException());

    expect(
      await repository.loadFirstPage(),
      const FeedLoadResult(hasMore: true, isStale: true),
    );
    expect(await feedIds(), ['a1']);
  });

  test('offline with nothing cached surfaces the network error', () async {
    when(
      () => api.getFeed(page: 1, topicId: null, source: null),
    ).thenThrow(const NetworkException());

    expect(repository.loadFirstPage, throwsA(isA<NetworkException>()));
  });

  test(
    'refresh adds new stories, updates and drops deleted ones, keeps the scroll window',
    () async {
      stubPage(page([story('a1', 9), story('a2', 8)], next: 'feed_2'));
      stubPage(page([story('a3', 7)], next: 'feed_3'), cursor: 'feed_2');
      await repository.loadFirstPage();
      await repository.loadNextPage();

      when(() => api.getFeedUpdates(any())).thenAnswer(
        (_) async => FeedUpdatesResponse(
          deletedItems: const ['a2'],
          serverTime: DateTime.utc(2026, 9, 14, 12),
        ),
      );
      stubPage(
        page([story('a0', 10), story('a1', 9, likes: 99)], next: 'feed_2'),
      );

      final result = await repository.refresh();

      expect(result.newStories, 1);
      final feed = await repository.watchFeed().first;
      expect(feed.map((a) => a.id), ['a0', 'a1', 'a3']);
      expect(feed[1].likes, 99);

      stubPage(page(const []), cursor: 'feed_3');
      await repository.loadNextPage();
      verify(
        () => api.getFeed(cursor: 'feed_3', topicId: null, source: null),
      ).called(1);
    },
  );

  test('the feed stream follows every write, not just feed loads', () async {
    stubPage(page([story('a1', 9)]));
    await repository.loadFirstPage();

    final emissions = <List<Article>>[];
    final subscription = repository.watchFeed().listen(emissions.add);
    await pumpEventQueue();

    await db.bookmarksDao.setBookmarked('a1', bookmarked: true);
    await pumpEventQueue();

    expect(emissions.last.single.isBookmarked, isTrue);
    await subscription.cancel();
  });
}
