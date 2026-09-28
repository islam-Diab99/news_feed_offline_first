import '../entities/paged_articles.dart';
import '../entities/topic.dart';

abstract interface class SearchRepository {
  Future<PagedArticles> search(
    String query, {
    String? topicId,
    String? source,
    String? cursor,
  });

  Future<List<Topic>> topics();

  Future<List<String>> sources({String? topicId});
}
