// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_dao.dart';

// ignore_for_file: type=lint
mixin _$BookmarksDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArticlesTable get articles => attachedDatabase.articles;
  $BookmarksTable get bookmarks => attachedDatabase.bookmarks;
  $PendingMutationsTable get pendingMutations =>
      attachedDatabase.pendingMutations;
  BookmarksDaoManager get managers => BookmarksDaoManager(this);
}

class BookmarksDaoManager {
  final _$BookmarksDaoMixin _db;
  BookmarksDaoManager(this._db);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db.attachedDatabase, _db.articles);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db.attachedDatabase, _db.bookmarks);
  $$PendingMutationsTableTableManager get pendingMutations =>
      $$PendingMutationsTableTableManager(
        _db.attachedDatabase,
        _db.pendingMutations,
      );
}
