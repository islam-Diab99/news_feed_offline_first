import '../../core/error/app_exception.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/article_detail.dart';
import '../../domain/entities/article_update.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/services/article_update_bus.dart';
import '../datasources/local/local_store.dart';
import '../datasources/remote/api_client.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  ArticleRepositoryImpl({
    required ApiClient api,
    required LocalStore store,
    required ArticleUpdateBus bus,
  }) : _api = api,
       _store = store,
       _bus = bus;

  final ApiClient _api;
  final LocalStore _store;
  final ArticleUpdateBus _bus;

  @override
  Future<ArticleDetailResult> detail(String id) async {
    try {
      final response = await _api.getArticle(id);
      switch (response) {
        case ArticleDetailData(:final detail):
          final cached = await _store.article(id);
          var merged = cached != null && cached.version >= detail.article.version
              ? detail.withArticle(cached)
              : detail;
     
          final bookmarked = await _store.isBookmarked(id);
          if (merged.article.isBookmarked != bookmarked) {
            merged = merged.withArticle(
              merged.article.copyWith(isBookmarked: bookmarked),
            );
          }
          await _store.saveDetail(merged);
          _bus.publish(ArticleChanged(merged.article));
          return ArticleDetailAvailable(
            merged,
            related: await _resolveRelated(merged.relatedIds),
          );
        case ArticleUnavailable(:final articleId, :final reason):
          await _store.removeArticle(articleId);
          _bus.publish(ArticleRemoved(articleId));
          return ArticleDetailUnavailable(articleId, reason: reason);
      }
    } on NetworkException {
      final cached = await _store.detail(id);
      if (cached == null) rethrow;
      return ArticleDetailAvailable(
        cached.detail,
        related: await _resolveRelated(
          cached.detail.relatedIds,
          localOnly: true,
        ),
        isStale: true,
      );
    }
  }

  Future<List<Article>> _resolveRelated(
    List<String> ids, {
    bool localOnly = false,
  }) async {
    final related = <Article>[];
    for (final id in ids.take(3)) {
      final cached = await _store.article(id);
      if (cached != null) {
        related.add(cached);
        continue;
      }
      if (localOnly) continue;
      try {
        final response = await _api.getArticle(id);
        if (response is ArticleDetailData) {
          final hydrated = await _store.withLocalState([
            response.detail.article,
          ]);
          await _store.upsertArticles(hydrated);
          related.add(hydrated.single);
        }
      } on AppException catch (_) {}
    }
    return related;
  }
}
