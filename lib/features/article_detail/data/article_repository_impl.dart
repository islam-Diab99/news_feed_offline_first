import 'package:rxdart/rxdart.dart';

import '../../../core/articles/data/local/daos/article_details_dao.dart';
import '../../../core/articles/data/local/daos/articles_dao.dart';
import '../../../core/articles/data/local/db_transaction.dart';
import '../../../core/articles/data/remote/api_client.dart';
import '../../../core/articles/domain/entities/article_detail.dart';
import '../../../core/error/app_exception.dart';
import '../domain/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  ArticleRepositoryImpl({
    required ApiClient api,
    required ArticlesDao articles,
    required ArticleDetailsDao details,
    required DbTransaction transaction,
  }) : _api = api,
       _articles = articles,
       _details = details,
       _transaction = transaction;

  static const _relatedLimit = 3;

  final ApiClient _api;
  final ArticlesDao _articles;
  final ArticleDetailsDao _details;
  final DbTransaction _transaction;

  @override
  Future<DetailFetch> fetchDetail(String id) async {
    try {
      switch (await _api.getArticle(id)) {
        case ArticleDetailData(:final detail):
          await _transaction(() async {
            await _articles.saveServerArticles([detail.article]);
            await _details.saveDetail(detail);
          });
          await _cacheMissing(detail.relatedIds.take(_relatedLimit));
          return DetailFetch.fresh;
        case ArticleUnavailable():
          await _articles.deleteArticles([id]);
          return DetailFetch.unavailable;
      }
    } on NetworkException {
      if (await _details.hasDetail(id)) return DetailFetch.stale;
      rethrow;
    }
  }

  @override
  Stream<ArticleDetailView?> watchDetail(String id) {
    return _details.watchDetail(id).switchMap((detail) {
      if (detail == null) return Stream.value(null);
      return _articles
          .watchArticlesById(detail.relatedIds.take(_relatedLimit).toList())
          .map((related) => ArticleDetailView(detail, related: related));
    });
  }

  Future<void> _cacheMissing(Iterable<String> ids) async {
    final known = await _articles.existingIds(ids);
    final fetched = await Future.wait(
      ids.where((id) => !known.contains(id)).map((id) async {
        try {
          final response = await _api.getArticle(id);
          return response is ArticleDetailData ? response.detail.article : null;
        } on AppException {
          return null;
        }
      }),
    );
    await _articles.saveServerArticles(fetched.nonNulls);
  }
}
