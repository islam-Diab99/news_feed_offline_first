import 'package:uuid/uuid.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/article_update.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../../domain/services/article_update_bus.dart';
import '../datasources/local/local_store.dart';
import '../datasources/remote/api_client.dart';
import '../models/outbox_mutation.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  BookmarkRepositoryImpl({
    required ApiClient api,
    required LocalStore store,
    required ConnectivityService connectivity,
    required ArticleUpdateBus bus,
    Uuid uuid = const Uuid(),
  }) : _api = api,
       _store = store,
       _connectivity = connectivity,
       _bus = bus,
       _uuid = uuid;

  final ApiClient _api;
  final LocalStore _store;
  final ConnectivityService _connectivity;
  final ArticleUpdateBus _bus;
  final Uuid _uuid;

  @override
  Future<List<Article>> bookmarks() => _store.bookmarkedArticles();

  @override
  Future<void> toggle(Article article) async {
    final bookmarked = !article.isBookmarked;
    final patched = article.copyWith(isBookmarked: bookmarked);

    if (bookmarked) {
      await _store.saveBookmark(patched);
    } else {
      await _store.removeBookmark(article.id);
    }
    await _store.upsertArticles([patched]);
    _bus.publish(ArticleChanged(patched));

    if (!_connectivity.isOnline) {
      await _enqueue(article.id, bookmarked);
      return;
    }
    try {
      await _api.setBookmark(article.id, bookmarked: bookmarked);
    } on AppException {
      await _enqueue(article.id, bookmarked);
    }
  }

  Future<void> _enqueue(String articleId, bool bookmarked) async {
    final stale = (await _store.pendingMutations())
        .where(
          (m) =>
              m.op == OutboxMutation.opSetBookmark && m.articleId == articleId,
        )
        .map((m) => m.idempotencyKey);
    await _store.removeMutations(stale);

    await _store.enqueueMutation(
      OutboxMutation(
        idempotencyKey: _uuid.v4(),
        op: OutboxMutation.opSetBookmark,
        articleId: articleId,
        payload: {'articleId': articleId, 'bookmarked': bookmarked},
        queuedAt: DateTime.now(),
      ),
    );
  }
}
