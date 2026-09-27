// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_dao.dart';

// ignore_for_file: type=lint
mixin _$FeedDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArticlesTable get articles => attachedDatabase.articles;
  $FeedEntriesTable get feedEntries => attachedDatabase.feedEntries;
  $FeedsTable get feeds => attachedDatabase.feeds;
  $KeyValuesTable get keyValues => attachedDatabase.keyValues;
  FeedDaoManager get managers => FeedDaoManager(this);
}

class FeedDaoManager {
  final _$FeedDaoMixin _db;
  FeedDaoManager(this._db);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db.attachedDatabase, _db.articles);
  $$FeedEntriesTableTableManager get feedEntries =>
      $$FeedEntriesTableTableManager(_db.attachedDatabase, _db.feedEntries);
  $$FeedsTableTableManager get feeds =>
      $$FeedsTableTableManager(_db.attachedDatabase, _db.feeds);
  $$KeyValuesTableTableManager get keyValues =>
      $$KeyValuesTableTableManager(_db.attachedDatabase, _db.keyValues);
}
