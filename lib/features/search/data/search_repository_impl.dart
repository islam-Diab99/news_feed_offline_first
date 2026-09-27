import '../../../core/articles/data/local/daos/articles_dao.dart';
import '../../../core/articles/data/remote/api_client.dart';
import '../../../core/articles/domain/entities/article.dart';
import '../../../core/articles/domain/entities/paged_articles.dart';
import '../../../core/error/app_exception.dart';
import '../domain/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required ApiClient api, required ArticlesDao articles})
    : _api = api,
      _articles = articles;

  final ApiClient _api;
  final ArticlesDao _articles;

  @override
  Future<PagedArticles> search(
    String query, {
    String? topicId,
    String? source,
    int page = 1,
  }) async {
    try {
      final response = await _api.search(
        query,
        page: page,
        topicId: topicId,
        source: source,
      );
      await _articles.saveServerArticles(response.items);
      return PagedArticles(
        items: await _articles.articlesById(
          response.items.map((a) => a.id).toList(),
        ),
        nextCursor: response.nextCursor,
        total: response.total,
      );
    } on NetworkException {
      final hits = await _articles.searchCached(
        query,
        topicId: topicId,
        source: source,
      );
      return PagedArticles(items: hits, total: hits.length, isStale: true);
    }
  }

  @override
  Stream<List<Article>> watchResults(List<String> ids) =>
      _articles.watchArticlesById(ids);
}
