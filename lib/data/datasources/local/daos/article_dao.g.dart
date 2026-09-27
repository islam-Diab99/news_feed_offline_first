// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_dao.dart';

// ignore_for_file: type=lint
mixin _$ArticleDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArticlesTable get articles => attachedDatabase.articles;
  $ArticleDetailsTable get articleDetails => attachedDatabase.articleDetails;
  $BookmarksTable get bookmarks => attachedDatabase.bookmarks;
  $FeedEntriesTable get feedEntries => attachedDatabase.feedEntries;
  $PendingMutationsTable get pendingMutations =>
      attachedDatabase.pendingMutations;
  ArticleDaoManager get managers => ArticleDaoManager(this);
}

class ArticleDaoManager {
  final _$ArticleDaoMixin _db;
  ArticleDaoManager(this._db);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db.attachedDatabase, _db.articles);
  $$ArticleDetailsTableTableManager get articleDetails =>
      $$ArticleDetailsTableTableManager(
        _db.attachedDatabase,
        _db.articleDetails,
      );
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db.attachedDatabase, _db.bookmarks);
  $$FeedEntriesTableTableManager get feedEntries =>
      $$FeedEntriesTableTableManager(_db.attachedDatabase, _db.feedEntries);
  $$PendingMutationsTableTableManager get pendingMutations =>
      $$PendingMutationsTableTableManager(
        _db.attachedDatabase,
        _db.pendingMutations,
      );
}
