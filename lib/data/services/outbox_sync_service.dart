import 'dart:async';

import '../../core/error/app_exception.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/services/sync_service.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/daos/articles_dao.dart';
import '../datasources/local/daos/outbox_dao.dart';
import '../datasources/local/db_transaction.dart';
import '../datasources/remote/api_client.dart';
import '../models/outbox_mutation.dart';

class OutboxSyncService implements SyncService {
  OutboxSyncService({
    required ApiClient api,
    required ArticlesDao articles,
    required OutboxDao outbox,
    required DbTransaction transaction,
    required ConnectivityService connectivity,
  }) : _api = api,
       _articles = articles,
       _outbox = outbox,
       _transaction = transaction,
       _connectivity = connectivity;

  final ApiClient _api;
  final ArticlesDao _articles;
  final OutboxDao _outbox;
  final DbTransaction _transaction;
  final ConnectivityService _connectivity;

  final _activityController = StreamController<SyncActivity>.broadcast();
  StreamSubscription<bool>? _subscription;
  bool _syncing = false;

  @override
  Stream<int> get pendingCount => _outbox.watchCount();

  @override
  Stream<SyncActivity> get syncActivity => _activityController.stream;

  @override
  void start() {
    _subscription = _connectivity.onStatusChange.listen((online) {
      if (online) unawaited(syncNow());
    });
    if (_connectivity.isOnline) unawaited(syncNow());
  }

  @override
  Future<void> syncNow() async {
    if (_syncing || !_connectivity.isOnline) return;
    _syncing = true;
    try {
      final pending = await _outbox.pending();
      if (pending.isEmpty) return;
      _activityController.add(SyncStarted(pending.length));

      final response = await _api.sync(pending.map(_toWire).toList());
      final applied = response.applied.toSet();
      final conflicted = {for (final a in response.conflicts) a.id};

      await _transaction(() async {
        for (final m in pending) {
          if (m.kind == MutationKind.reaction &&
              applied.contains(m.idempotencyKey) &&
              !conflicted.contains(m.articleId)) {
            await _articles.confirmReaction(m.articleId, liked: m.value);
          }
        }
        await _articles.saveServerArticles(response.conflicts);
        await _outbox.settle(applied);
      });
      _activityController.add(SyncSucceeded(applied.length));
    } on AppException {
      _activityController.add(const SyncFailed());
    } finally {
      _syncing = false;
    }
  }

  OutboxMutation _toWire(PendingMutation m) => OutboxMutation(
    idempotencyKey: m.idempotencyKey,
    op: switch (m.kind) {
      MutationKind.reaction => OutboxMutation.opSetReaction,
      MutationKind.bookmark => OutboxMutation.opSetBookmark,
    },
    articleId: m.articleId,
    payload: switch (m.kind) {
      MutationKind.reaction => {
        'articleId': m.articleId,
        'reaction': m.value ? 'like' : 'unlike',
      },
      MutationKind.bookmark => {
        'articleId': m.articleId,
        'bookmarked': m.value,
      },
    },
    queuedAt: m.queuedAt,
  );

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _activityController.close();
  }
}
