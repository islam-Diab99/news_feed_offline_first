import '../../core/error/app_exception.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/api_client.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({required ApiClient api, required AppDatabase db})
    : _api = api,
      _db = db;

  final ApiClient _api;
  final AppDatabase _db;

  static String feedKey({String? topicId, String? source}) =>
      '${topicId ?? '*'}|${source ?? '*'}';

  @override
  Stream<List<Article>> watchFeed({String? topicId, String? source}) =>
      _db.articleDao.watchFeed(feedKey(topicId: topicId, source: source));

  @override
  Future<FeedLoadResult> loadFirstPage({
    String? topicId,
    String? source,
  }) async {
    final key = feedKey(topicId: topicId, source: source);
    try {
      final page = await _api.getFeed(
        page: 1,
        topicId: topicId,
        source: source,
      );
      await _db.transaction(() async {
        await _db.feedDao.clearEntries(key);
        await _savePage(key, page);
      });
      return FeedLoadResult(hasMore: page.nextCursor != null);
    } on NetworkException {
      final cached = await _db.feedDao.feed(key);
      if (cached == null) rethrow;
      return FeedLoadResult(hasMore: cached.nextCursor != null, isStale: true);
    }
  }

  @override
  Future<FeedLoadResult> loadNextPage({String? topicId, String? source}) async {
    final key = feedKey(topicId: topicId, source: source);
    final cursor = (await _db.feedDao.feed(key))?.nextCursor;
    if (cursor == null) return const FeedLoadResult(hasMore: false);

    final page = await _api.getFeed(
      cursor: cursor,
      topicId: topicId,
      source: source,
    );
    await _db.transaction(() => _savePage(key, page));
    return FeedLoadResult(hasMore: page.nextCursor != null);
  }

  @override
  Future<FeedRefreshResult> refresh({String? topicId, String? source}) async {
    final key = feedKey(topicId: topicId, source: source);
    final since =
        await _db.feedDao.lastSync() ??
        DateTime.now().subtract(const Duration(days: 1));
    final updates = await _api.getFeedUpdates(since);
    final head = await _api.getFeed(page: 1, topicId: topicId, source: source);

    return _db.transaction(() async {
      final known = await _db.feedDao.entryIds(key);
      final hasCursor = await _db.feedDao.feed(key) != null;

      await _db.feedDao.setLastSync(updates.serverTime);
      await _db.articleDao.deleteArticles(updates.deletedItems);
      await _db.articleDao.saveServerArticles(head.items);
      await _db.feedDao.addEntries(key, head.items.map((a) => a.id));
      // An existing cursor already points past everything loaded so far;
      // resetting it to page 2 would throw away the user's scroll window.
      if (!hasCursor) await _db.feedDao.setCursor(key, head.nextCursor);

      return FeedRefreshResult(
        newStories: head.items.where((a) => !known.contains(a.id)).length,
      );
    });
  }

  Future<void> _savePage(String key, FeedPageResponse page) async {
    await _db.articleDao.saveServerArticles(page.items);
    await _db.feedDao.addEntries(key, page.items.map((a) => a.id));
    await _db.feedDao.setCursor(key, page.nextCursor);
  }
}
