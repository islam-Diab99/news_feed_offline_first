// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_details_dao.dart';

// ignore_for_file: type=lint
mixin _$ArticleDetailsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArticlesTable get articles => attachedDatabase.articles;
  $ArticleDetailsTable get articleDetails => attachedDatabase.articleDetails;
  $BookmarksTable get bookmarks => attachedDatabase.bookmarks;
  $PendingMutationsTable get pendingMutations =>
      attachedDatabase.pendingMutations;
  ArticleDetailsDaoManager get managers => ArticleDetailsDaoManager(this);
}

class ArticleDetailsDaoManager {
  final _$ArticleDetailsDaoMixin _db;
  ArticleDetailsDaoManager(this._db);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db.attachedDatabase, _db.articles);
  $$ArticleDetailsTableTableManager get articleDetails =>
      $$ArticleDetailsTableTableManager(
        _db.attachedDatabase,
        _db.articleDetails,
      );
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db.attachedDatabase, _db.bookmarks);
  $$PendingMutationsTableTableManager get pendingMutations =>
      $$PendingMutationsTableTableManager(
        _db.attachedDatabase,
        _db.pendingMutations,
      );
}
