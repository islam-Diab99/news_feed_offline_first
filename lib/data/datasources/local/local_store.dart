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

  /// Re-applies locally owned state onto articles that arrived from the
  /// network: the bookmark set, plus any reaction still waiting in the outbox.
  /// Both are local-first user actions, so they win over whatever the server
  /// echoed back — otherwise a plain feed load silently undoes them.
  Future<List<Article>> withLocalState(List<Article> articles);

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

/// The latest queued intent per article, newest mutation winning.
Map<String, bool> pendingLikesFrom(List<OutboxMutation> mutations) {
  final intents = <String, bool>{};
  for (final mutation in mutations) {
    if (mutation.op == OutboxMutation.opSetReaction) {
      intents[mutation.articleId] = mutation.payload['reaction'] == 'like';
    }
  }
  return intents;
}

/// Shared merge semantics for [LocalStore.withLocalState], so every store
/// implementation (and its test double) reconciles the same way.
List<Article> applyLocalState(
  List<Article> articles, {
  required bool Function(String id) isBookmarked,
  required Map<String, bool> pendingLikes,
}) {
  return articles.map((article) {
    final bookmarked = isBookmarked(article.id);
    final queuedLike = pendingLikes[article.id];
    final flipLike = queuedLike != null && queuedLike != article.isLiked;
    if (!flipLike && bookmarked == article.isBookmarked) return article;

    return article.copyWith(
      isBookmarked: bookmarked,
      isLiked: flipLike ? queuedLike : null,
      // Keep the count consistent with the flip we just re-applied.
      likes: !flipLike
          ? null
          : queuedLike
          ? article.likes + 1
          : (article.likes > 0 ? article.likes - 1 : 0),
    );
  }).toList();
}
