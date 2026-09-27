import '../../../core/articles/domain/entities/article.dart';
import '../../../core/articles/domain/entities/paged_articles.dart';

abstract interface class SearchRepository {
  Future<PagedArticles> search(
    String query, {
    String? topicId,
    String? source,
    int page = 1,
  });

  /// Keeps shown results live: likes and bookmarks made anywhere re-emit.
  Stream<List<Article>> watchResults(List<String> ids);
}
