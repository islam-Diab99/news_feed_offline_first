import '../../core/error/app_exception.dart';
import '../../domain/entities/paged_articles.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/local/local_store.dart';
import '../datasources/remote/api_client.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({
    required ApiClient api,
    required LocalStore store,
    this.cacheTtl = const Duration(minutes: 30),
  }) : _api = api,
       _store = store;

  final ApiClient _api;
  final LocalStore _store;
  final Duration cacheTtl;

  static String filterKey({String? topicId, String? source}) =>
      '${topicId ?? '*'}|${source ?? '*'}';

  @override
  Future<PagedArticles> firstPage({String? topicId, String? source}) async {
    final key = filterKey(topicId: topicId, source: source);
    try {
      final response = await _api.getFeed(
        page: 1,
        topicId: topicId,
        source: source,
      );
      final items = await _store.withLocalState(response.items);
      await _store.saveFeedSnapshot(
        key,
        items,
        nextCursor: response.nextCursor,
      );
      return PagedArticles(
        items: items,
        nextCursor: response.nextCursor,
        total: response.total,
      );
    } on NetworkException {
      final cached = await _cachedFeed(key);
      if (cached == null) rethrow;
      return cached;
    }
  }

  @override
  Future<PagedArticles> nextPage(
    String cursor, {
    String? topicId,
    String? source,
  }) async {
    final response = await _api.getFeed(
      cursor: cursor,
      topicId: topicId,
      source: source,
    );

    final items = await _store.withLocalState(response.items);
    final key = filterKey(topicId: topicId, source: source);
    final snapshot = await _store.feedSnapshot(key);
    if (snapshot != null) {
      final seen = snapshot.articles.map((a) => a.id).toSet();
      await _store.saveFeedSnapshot(key, [
        ...snapshot.articles,
        ...items.where((a) => !seen.contains(a.id)),
      ], nextCursor: response.nextCursor);
    } else {
      await _store.upsertArticles(items);
    }

    return PagedArticles(
      items: items,
      nextCursor: response.nextCursor,
      total: response.total,
    );
  }

  @override
  Future<FeedRefreshResult> refresh({String? topicId, String? source}) async {
    final since =
        await _store.lastFeedSyncTime() ??
        DateTime.now().subtract(const Duration(days: 1));
    final updates = await _api.getFeedUpdates(since);
    await _store.setLastFeedSyncTime(updates.serverTime);

    for (final id in updates.deletedItems) {
      await _store.removeArticle(id);
    }

    final head = await _api.getFeed(page: 1, topicId: topicId, source: source);
    final items = await _store.withLocalState(head.items);
    await _store.upsertArticles(items);

    final key = filterKey(topicId: topicId, source: source);
    final snapshot = await _store.feedSnapshot(key);
    if (snapshot != null) {
      final headIds = items.map((a) => a.id).toSet();
      final deleted = updates.deletedItems.toSet();
      await _store.saveFeedSnapshot(key, [
        ...items,
        ...snapshot.articles.where(
          (a) => !headIds.contains(a.id) && !deleted.contains(a.id),
        ),
      ], nextCursor: snapshot.nextCursor);
    }

    return FeedRefreshResult(
      head: PagedArticles(
        items: items,
        nextCursor: head.nextCursor,
        total: head.total,
      ),
      deletedIds: updates.deletedItems,
    );
  }

  Future<PagedArticles?> _cachedFeed(String key) async {
    final snapshot = await _store.feedSnapshot(key);
    if (snapshot == null || snapshot.articles.isEmpty) return null;
    return PagedArticles(
      items: snapshot.articles,
      nextCursor: null,
      isStale: true,
    );
  }

  bool isExpired(DateTime savedAt) =>
      DateTime.now().toUtc().difference(savedAt.toUtc()) > cacheTtl;
}
