import 'app_database.dart';

/// Groups writes from several DAOs into one atomic unit, so a repository can
/// span tables without holding the whole database.
class DbTransaction {
  const DbTransaction(this._db);

  final AppDatabase _db;

  Future<T> call<T>(Future<T> Function() action) => _db.transaction(action);
}
