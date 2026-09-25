import 'dart:async';

import '../../core/error/app_exception.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/article_update.dart';
import '../../domain/services/article_update_bus.dart';
import '../../domain/services/sync_service.dart';
import '../datasources/local/local_store.dart';
import '../datasources/remote/api_client.dart';

class OutboxSyncService implements SyncService {
  OutboxSyncService({
    required ApiClient api,
    required LocalStore store,
    required ConnectivityService connectivity,
    required ArticleUpdateBus bus,
  }) : _api = api,
       _store = store,
       _connectivity = connectivity,
       _bus = bus;

  final ApiClient _api;
  final LocalStore _store;
  final ConnectivityService _connectivity;
  final ArticleUpdateBus _bus;

  final _pendingController = StreamController<int>.broadcast();
  final _activityController = StreamController<SyncActivity>.broadcast();
  StreamSubscription<bool>? _subscription;
  StreamSubscription<void>? _outboxSubscription;
  bool _syncing = false;

  @override
  Stream<int> get pendingCount async* {
    yield (await _store.pendingMutations()).length;
    yield* _pendingController.stream;
  }

  @override
  Stream<SyncActivity> get syncActivity => _activityController.stream;

  @override
  void start() {
    _subscription = _connectivity.onStatusChange.listen((online) {
      if (online) unawaited(syncNow());
    });
    _outboxSubscription = _store.outboxChanges.listen(
      (_) => unawaited(_emitPending()),
    );
    if (_connectivity.isOnline) unawaited(syncNow());
  }

  @override
  Future<void> syncNow() async {
    if (_syncing || !_connectivity.isOnline) return;
    _syncing = true;
    try {
      final mutations = await _store.pendingMutations();
      if (mutations.isEmpty) return;
      _activityController.add(SyncStarted(mutations.length));

      final response = await _api.sync(mutations);
      final appliedKeys = response.applied.toSet();
      final settled = mutations
          .where((m) => appliedKeys.contains(m.idempotencyKey))
          .map((m) => m.articleId)
          .toSet();
      await _store.removeMutations(response.applied);

      for (final serverArticle in response.conflicts) {
        settled.remove(serverArticle.id);
        final local = await _store.article(serverArticle.id);
        final reconciled = serverArticle.copyWith(
          isBookmarked: local?.isBookmarked ?? serverArticle.isBookmarked,
        );
        await _store.upsertArticles([reconciled]);
        _bus.publish(ArticleChanged(reconciled));
      }

      // The queue has drained, so the local state is now the agreed state.
      // Republish it: listeners that loaded before the sync would otherwise
      // keep showing the pre-sync value until a manual refresh.
      for (final id in settled) {
        final local = await _store.article(id);
        if (local != null) _bus.publish(ArticleChanged(local));
      }
      _activityController.add(SyncSucceeded(response.applied.length));
    } on AppException {
      _activityController.add(const SyncFailed());
    } finally {
      _syncing = false;
      await _emitPending();
    }
  }

  Future<void> _emitPending() async {
    if (_pendingController.isClosed) return;
    _pendingController.add((await _store.pendingMutations()).length);
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _outboxSubscription?.cancel();
    await _pendingController.close();
    await _activityController.close();
  }
}
