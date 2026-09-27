import '../../core/error/app_exception.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/daos/bookmarks_dao.dart';
import '../datasources/local/daos/outbox_dao.dart';
import '../datasources/local/db_transaction.dart';
import '../datasources/remote/api_client.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  BookmarkRepositoryImpl({
    required ApiClient api,
    required BookmarksDao bookmarks,
    required OutboxDao outbox,
    required DbTransaction transaction,
    required ConnectivityService connectivity,
  }) : _api = api,
       _bookmarks = bookmarks,
       _outbox = outbox,
       _transaction = transaction,
       _connectivity = connectivity;

  final ApiClient _api;
  final BookmarksDao _bookmarks;
  final OutboxDao _outbox;
  final DbTransaction _transaction;
  final ConnectivityService _connectivity;

  @override
  Stream<List<Article>> watchBookmarks() => _bookmarks.watchBookmarks();

  @override
  Future<void> toggle(Article article) async {
    final bookmarked = !article.isBookmarked;
    final queued = await _transaction(() async {
      await _bookmarks.setBookmarked(article.id, bookmarked: bookmarked);
      return _outbox.put(MutationKind.bookmark, article.id, bookmarked);
    });

    if (!_connectivity.isOnline) return;
    try {
      await _api.setBookmark(article.id, bookmarked: bookmarked);
      await _outbox.settle([queued.key]);
    } on AppException {
      // Stays in the outbox; the local bookmark is already the truth.
    }
  }
}
