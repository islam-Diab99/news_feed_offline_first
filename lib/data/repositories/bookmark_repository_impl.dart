import '../../core/error/app_exception.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/api_client.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  BookmarkRepositoryImpl({
    required ApiClient api,
    required AppDatabase db,
    required ConnectivityService connectivity,
  }) : _api = api,
       _db = db,
       _connectivity = connectivity;

  final ApiClient _api;
  final AppDatabase _db;
  final ConnectivityService _connectivity;

  @override
  Stream<List<Article>> watchBookmarks() => _db.articleDao.watchBookmarks();

  @override
  Future<void> toggle(Article article) async {
    final bookmarked = !article.isBookmarked;
    final queued = await _db.transaction(() async {
      await _db.articleDao.setBookmarked(article.id, bookmarked: bookmarked);
      return _db.outboxDao.put(MutationKind.bookmark, article.id, bookmarked);
    });

    if (!_connectivity.isOnline) return;
    try {
      await _api.setBookmark(article.id, bookmarked: bookmarked);
      await _db.outboxDao.settle([queued.key]);
    } on AppException {
      // Stays in the outbox; the local bookmark is already the truth.
    }
  }
}
