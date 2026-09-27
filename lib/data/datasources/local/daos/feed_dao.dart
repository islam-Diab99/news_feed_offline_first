import 'package:drift/drift.dart';

import '../app_database.dart';

part 'feed_dao.g.dart';

@DriftAccessor(tables: [FeedEntries, Feeds, KeyValues])
class FeedDao extends DatabaseAccessor<AppDatabase> with _$FeedDaoMixin {
  FeedDao(super.attachedDatabase);

  static const _lastSyncKey = 'feed.lastSync';

  Future<FeedRow?> feed(String feedKey) => (select(
    feeds,
  )..where((f) => f.feedKey.equals(feedKey))).getSingleOrNull();

  Future<void> setCursor(String feedKey, String? nextCursor) =>
      into(feeds).insertOnConflictUpdate(
        FeedsCompanion.insert(feedKey: feedKey, nextCursor: Value(nextCursor)),
      );

  Future<Set<String>> entryIds(String feedKey) async {
    final rows = await (select(
      feedEntries,
    )..where((e) => e.feedKey.equals(feedKey))).get();
    return {for (final row in rows) row.articleId};
  }

  Future<void> addEntries(String feedKey, Iterable<String> articleIds) {
    return batch((b) {
      b.insertAll(feedEntries, [
        for (final id in articleIds)
          FeedEntriesCompanion.insert(feedKey: feedKey, articleId: id),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> clearEntries(String feedKey) =>
      (delete(feedEntries)..where((e) => e.feedKey.equals(feedKey))).go();

  Future<DateTime?> lastSync() async {
    final row = await (select(
      keyValues,
    )..where((kv) => kv.key.equals(_lastSyncKey))).getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value);
  }

  Future<void> setLastSync(DateTime time) =>
      into(keyValues).insertOnConflictUpdate(
        KeyValuesCompanion.insert(
          key: _lastSyncKey,
          value: time.toUtc().toIso8601String(),
        ),
      );
}
