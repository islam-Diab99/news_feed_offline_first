import '../entities/paged_articles.dart';

class FeedRefreshResult {
  const FeedRefreshResult({required this.head, this.deletedIds = const []});

  final PagedArticles head;
  final List<String> deletedIds;
}

abstract interface class FeedRepository {
  Future<PagedArticles> firstPage({String? topicId, String? source});

  Future<PagedArticles> nextPage(
    String cursor, {
    String? topicId,
    String? source,
  });

  Future<FeedRefreshResult> refresh({String? topicId, String? source});
}
