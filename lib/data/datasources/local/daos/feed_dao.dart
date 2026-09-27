import 'package:drift/drift.dart';

import '../../../../domain/entities/article.dart';
import '../app_database.dart';
import '../article_read_model.dart';

part 'feed_dao.g.dart';

/// Owns feed membership ([FeedEntries]), per-feed cursors ([Feeds]) and the
/// incremental-sync watermark. Order and dedup are the query's job: a feed is
/// a set of entries sorted by publish time, not a list kept in Dart.
@DriftAccessor(
  tables: [
    FeedEntries,
    Feeds,
    KeyValues,
    Articles,
    Bookmarks,
    PendingMutations,
  ],
)
class FeedDao extends DatabaseAccessor<AppDatabase>
    with _$FeedDaoMixin, ArticleReadModel {
  FeedDao(super.attachedDatabase);

  static const _lastSyncKey = 'feed.lastSync';

  Stream<List<Article>> watchFeed(String feedKey) {
    final query =
        selectArticles(
          joins: [
            innerJoin(
              feedEntries,
              feedEntries.articleId.equalsExp(articles.id) &
                  feedEntries.feedKey.equals(feedKey),
            ),
          ],
        )..orderBy([
          OrderingTerm.desc(articles.publishedAt),
          OrderingTerm.asc(articles.id),
        ]);
    return query.map(readArticle).watch();
  }

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
