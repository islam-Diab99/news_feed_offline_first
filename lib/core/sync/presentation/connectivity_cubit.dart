import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/connectivity_service.dart';
import '../sync_service.dart';

class ConnectivityState extends Equatable {
  const ConnectivityState({
    this.isOnline = true,
    this.isSimulatedOffline = false,
    this.pendingSyncCount = 0,
    this.isSyncing = false,
    this.syncingCount = 0,
    this.syncedCount,
  });

  final bool isOnline;
  final bool isSimulatedOffline;

  final int pendingSyncCount;

  final bool isSyncing;

  final int syncingCount;

  final int? syncedCount;

  ConnectivityState copyWith({
    bool? isOnline,
    bool? isSimulatedOffline,
    int? pendingSyncCount,
    bool? isSyncing,
    int? syncingCount,
    int? Function()? syncedCount,
  }) => ConnectivityState(
    isOnline: isOnline ?? this.isOnline,
    isSimulatedOffline: isSimulatedOffline ?? this.isSimulatedOffline,
    pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    isSyncing: isSyncing ?? this.isSyncing,
    syncingCount: syncingCount ?? this.syncingCount,
    syncedCount: syncedCount != null ? syncedCount() : this.syncedCount,
  );

  @override
  List<Object?> get props => [
    isOnline,
    isSimulatedOffline,
    pendingSyncCount,
    isSyncing,
    syncingCount,
    syncedCount,
  ];
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit({
    required ConnectivityController connectivity,
    required SyncService syncService,
  }) : _connectivity = connectivity,
       super(
         ConnectivityState(
           isOnline: connectivity.isOnline,
           isSimulatedOffline: connectivity.isSimulatedOffline,
         ),
       ) {
    _statusSubscription = connectivity.onStatusChange.listen((online) {
      emit(
        state.copyWith(
          isOnline: online,
          isSimulatedOffline: connectivity.isSimulatedOffline,
        ),
      );
    });
    _pendingSubscription = syncService.pendingCount.listen((count) {
      emit(state.copyWith(pendingSyncCount: count));
    });
    _activitySubscription = syncService.syncActivity.listen((activity) {
      switch (activity) {
        case SyncStarted(:final count):
          _syncedNoticeTimer?.cancel();
          emit(
            state.copyWith(
              isSyncing: true,
              syncingCount: count,
              syncedCount: () => null,
            ),
          );
        case SyncSucceeded(:final count):
          emit(state.copyWith(isSyncing: false, syncedCount: () => count));
          _syncedNoticeTimer?.cancel();
          _syncedNoticeTimer = Timer(const Duration(seconds: 3), () {
            if (!isClosed) emit(state.copyWith(syncedCount: () => null));
          });
        case SyncFailed():
          emit(state.copyWith(isSyncing: false));
      }
    });
  }

  final ConnectivityController _connectivity;
  late final StreamSubscription<bool> _statusSubscription;
  late final StreamSubscription<int> _pendingSubscription;
  late final StreamSubscription<SyncActivity> _activitySubscription;
  Timer? _syncedNoticeTimer;

  void toggleSimulatedOffline() {
    _connectivity.setSimulatedOffline(!_connectivity.isSimulatedOffline);
  }

  @override
  Future<void> close() async {
    _syncedNoticeTimer?.cancel();
    await _statusSubscription.cancel();
    await _pendingSubscription.cancel();
    await _activitySubscription.cancel();
    return super.close();
  }
}
