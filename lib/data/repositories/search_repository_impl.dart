import '../../core/error/app_exception.dart';
import '../../domain/entities/paged_articles.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/local/local_store.dart';
import '../datasources/remote/api_client.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required ApiClient api, required LocalStore store})
    : _api = api,
      _store = store;

  final ApiClient _api;
  final LocalStore _store;

  List<Topic>? _topics;
  final Map<String, List<String>> _sources = {};

  @override
  Future<PagedArticles> search(
    String query, {
    String? topicId,
    String? source,
    String? cursor,
  }) async {
    try {
      final response = await _api.search(
        query,
        page: _pageOf(cursor),
        topicId: topicId,
        source: source,
      );
      final items = await _store.withLocalState(response.items);
      await _store.upsertArticles(items);
      return PagedArticles(
        items: items,
        nextCursor: response.nextCursor,
        total: response.total,
      );
    } on NetworkException {
      final needle = query.trim().toLowerCase();
      final hits =
          (await _store.allArticles())
              .where((a) => topicId == null || a.topicId == topicId)
              .where((a) => source == null || a.source == source)
              .where(
                (a) =>
                    a.title.toLowerCase().contains(needle) ||
                    a.summary.toLowerCase().contains(needle) ||
                    a.tags.any((t) => t.toLowerCase().contains(needle)),
              )
              .toList()
            ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return PagedArticles(items: hits, total: hits.length, isStale: true);
    }
  }

  int _pageOf(String? cursor) =>
      cursor == null ? 1 : int.tryParse(cursor.split('_').last) ?? 1;

  @override
  Future<List<Topic>> topics() async {
    if (_topics != null) return _topics!;
    try {
      return _topics = await _api.getTopics();
    } on NetworkException {
      return const [];
    }
  }

  @override
  Future<List<String>> sources({String? topicId}) async {
    final key = topicId ?? '*';
    if (_sources.containsKey(key)) return _sources[key]!;
    try {
      return _sources[key] = await _api.getSources(topicId: topicId);
    } on NetworkException {
      return const [];
    }
  }
}
