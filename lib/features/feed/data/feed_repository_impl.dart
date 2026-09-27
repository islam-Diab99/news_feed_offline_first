import '../../../core/articles/data/local/daos/articles_dao.dart';
import '../../../core/articles/data/local/daos/feed_dao.dart';
import '../../../core/articles/data/local/db_transaction.dart';
import '../../../core/articles/data/remote/api_client.dart';
import '../../../core/articles/domain/entities/article.dart';
import '../../../core/error/app_exception.dart';
import '../domain/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({
    required ApiClient api,
    required ArticlesDao articles,
    required FeedDao feed,
    required DbTransaction transaction,
  }) : _api = api,
       _articles = articles,
       _feed = feed,
       _transaction = transaction;

  final ApiClient _api;
  final ArticlesDao _articles;
  final FeedDao _feed;
  final DbTransaction _transaction;

  static String feedKey({String? topicId, String? source}) =>
      '${topicId ?? '*'}|${source ?? '*'}';

  @override
  Stream<List<Article>> watchFeed({String? topicId, String? source}) =>
      _feed.watchFeed(feedKey(topicId: topicId, source: source));

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
      await _transaction(() async {
        await _feed.clearEntries(key);
        await _savePage(key, page);
      });
      return FeedLoadResult(hasMore: page.nextCursor != null);
    } on NetworkException {
      final cached = await _feed.feed(key);
      if (cached == null) rethrow;
      return FeedLoadResult(hasMore: cached.nextCursor != null, isStale: true);
    }
  }

  @override
  Future<FeedLoadResult> loadNextPage({String? topicId, String? source}) async {
    final key = feedKey(topicId: topicId, source: source);
    final cursor = (await _feed.feed(key))?.nextCursor;
    if (cursor == null) return const FeedLoadResult(hasMore: false);

    final page = await _api.getFeed(
      cursor: cursor,
      topicId: topicId,
      source: source,
    );
    await _transaction(() => _savePage(key, page));
    return FeedLoadResult(hasMore: page.nextCursor != null);
  }

  @override
  Future<FeedRefreshResult> refresh({String? topicId, String? source}) async {
    final key = feedKey(topicId: topicId, source: source);
    final since =
        await _feed.lastSync() ??
        DateTime.now().subtract(const Duration(days: 1));
    final updates = await _api.getFeedUpdates(since);
    final head = await _api.getFeed(page: 1, topicId: topicId, source: source);

    return _transaction(() async {
      final known = await _feed.entryIds(key);
      final hasCursor = await _feed.feed(key) != null;

      await _feed.setLastSync(updates.serverTime);
      await _articles.deleteArticles(updates.deletedItems);
      await _articles.saveServerArticles(head.items);
      await _feed.addEntries(key, head.items.map((a) => a.id));
      // An existing cursor already points past everything loaded so far;
      // resetting it to page 2 would throw away the user's scroll window.
      if (!hasCursor) await _feed.setCursor(key, head.nextCursor);

      return FeedRefreshResult(
        newStories: head.items.where((a) => !known.contains(a.id)).length,
      );
    });
  }

  Future<void> _savePage(String key, FeedPageResponse page) async {
    await _articles.saveServerArticles(page.items);
    await _feed.addEntries(key, page.items.map((a) => a.id));
    await _feed.setCursor(key, page.nextCursor);
  }
}
