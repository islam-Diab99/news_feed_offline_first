sealed class SyncActivity {
  const SyncActivity();
}

class SyncStarted extends SyncActivity {
  const SyncStarted(this.count);

  final int count;
}

class SyncSucceeded extends SyncActivity {
  const SyncSucceeded(this.count);

  final int count;
}

class SyncFailed extends SyncActivity {
  const SyncFailed();
}

abstract interface class SyncService {
  Stream<int> get pendingCount;

  Stream<SyncActivity> get syncActivity;

  void start();

  Future<void> syncNow();

  Future<void> dispose();
}
