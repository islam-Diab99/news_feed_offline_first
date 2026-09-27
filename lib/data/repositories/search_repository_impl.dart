import '../../core/error/app_exception.dart';
import '../../domain/entities/paged_articles.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/api_client.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required ApiClient api, required AppDatabase db})
    : _api = api,
      _db = db;

  final ApiClient _api;
  final AppDatabase _db;

  List<Topic>? _topics;
  final Map<String, List<String>> _sources = {};

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
      await _db.articleDao.saveServerArticles(response.items);
      return PagedArticles(
        items: await _db.articleDao.articlesById(
          response.items.map((a) => a.id).toList(),
        ),
        nextCursor: response.nextCursor,
        total: response.total,
      );
    } on NetworkException {
      final hits = await _db.articleDao.searchCached(
        query,
        topicId: topicId,
        source: source,
      );
      return PagedArticles(items: hits, total: hits.length, isStale: true);
    }
  }

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
