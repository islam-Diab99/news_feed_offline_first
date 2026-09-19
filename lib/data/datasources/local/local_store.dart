import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_detail.dart';
import '../../models/outbox_mutation.dart';

class CachedFeed {
  const CachedFeed({
    required this.articles,
    required this.savedAt,
    this.nextCursor,
  });

  final List<Article> articles;
  final DateTime savedAt;
  final String? nextCursor;
}

class CachedDetail {
  const CachedDetail({required this.detail, required this.savedAt});

  final ArticleDetail detail;
  final DateTime savedAt;
}

abstract interface class LocalStore {
  Future<void> saveFeedSnapshot(
    String filterKey,
    List<Article> articles, {
    String? nextCursor,
  });

  Future<CachedFeed?> feedSnapshot(String filterKey);

  Future<void> upsertArticles(List<Article> articles);

  Future<Article?> article(String id);

  Future<void> removeArticle(String id);

  Future<List<Article>> allArticles();

  Future<void> saveDetail(ArticleDetail detail);

  Future<CachedDetail?> detail(String id);

  Future<void> saveBookmark(Article article);

  Future<void> removeBookmark(String id);

  Future<List<Article>> bookmarkedArticles();

  Future<bool> isBookmarked(String id);

  Future<void> enqueueMutation(OutboxMutation mutation);

  Future<List<OutboxMutation>> pendingMutations();

  Future<void> removeMutations(Iterable<String> idempotencyKeys);

  Stream<void> get outboxChanges;

  Future<DateTime?> lastFeedSyncTime();

  Future<void> setLastFeedSyncTime(DateTime time);
}
