import 'package:rxdart/rxdart.dart';

import '../../core/error/app_exception.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/article_detail.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/api_client.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  ArticleRepositoryImpl({required ApiClient api, required AppDatabase db})
    : _api = api,
      _db = db;

  static const _relatedLimit = 3;

  final ApiClient _api;
  final AppDatabase _db;

  @override
  Future<DetailFetch> fetchDetail(String id) async {
    try {
      switch (await _api.getArticle(id)) {
        case ArticleDetailData(:final detail):
          await _db.articleDao.saveServerDetail(detail);
          await _cacheMissing(detail.relatedIds.take(_relatedLimit));
          return DetailFetch.fresh;
        case ArticleUnavailable():
          await _db.articleDao.deleteArticles([id]);
          return DetailFetch.unavailable;
      }
    } on NetworkException {
      if (await _db.articleDao.hasDetail(id)) return DetailFetch.stale;
      rethrow;
    }
  }

  @override
  Stream<ArticleDetailView?> watchDetail(String id) {
    return _db.articleDao.watchDetail(id).switchMap((detail) {
      if (detail == null) return Stream.value(null);
      return watchArticles(
        detail.relatedIds.take(_relatedLimit).toList(),
      ).map((related) => ArticleDetailView(detail, related: related));
    });
  }

  @override
  Stream<List<Article>> watchArticles(List<String> ids) =>
      _db.articleDao.watchArticlesById(ids);

  Future<void> _cacheMissing(Iterable<String> ids) async {
    final known = await _db.articleDao.existingIds(ids);
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
    await _db.articleDao.saveServerArticles(fetched.nonNulls);
  }
}
