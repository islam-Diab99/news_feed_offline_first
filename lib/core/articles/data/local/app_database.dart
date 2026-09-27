import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/article_detail.dart';
import '../models/article_detail_model.dart';
import 'daos/article_details_dao.dart';
import 'daos/articles_dao.dart';
import 'daos/bookmarks_dao.dart';
import 'daos/feed_dao.dart';
import 'daos/outbox_dao.dart';

part 'app_database.g.dart';

@DataClassName('ArticleRow')
@TableIndex(name: 'articles_published_at', columns: {#publishedAt})
class Articles extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  TextColumn get source => text()();
  TextColumn get authorName => text()();
  TextColumn get authorAvatar => text().nullable()();
  TextColumn get topicId => text()();
  DateTimeColumn get publishedAt => dateTime()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get tags => text().map(const StringListConverter())();
  IntColumn get likes => integer()();
  IntColumn get comments => integer()();
  BoolColumn get isLikedOnServer => boolean()();
  IntColumn get version => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ArticleDetailRow')
class ArticleDetails extends Table {
  TextColumn get articleId =>
      text().references(Articles, #id, onDelete: KeyAction.cascade)();
  TextColumn get body => text().map(const ContentBlocksConverter())();
  TextColumn get authorBio => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get readTimeMinutes => integer().nullable()();
  TextColumn get relatedIds => text().map(const StringListConverter())();

  @override
  Set<Column> get primaryKey => {articleId};
}

@DataClassName('BookmarkRow')
class Bookmarks extends Table {
  TextColumn get articleId =>
      text().references(Articles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {articleId};
}

@DataClassName('FeedEntryRow')
class FeedEntries extends Table {
  TextColumn get feedKey => text()();
  TextColumn get articleId =>
      text().references(Articles, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {feedKey, articleId};
}

@DataClassName('FeedRow')
class Feeds extends Table {
  TextColumn get feedKey => text()();
  TextColumn get nextCursor => text().nullable()();

  @override
  Set<Column> get primaryKey => {feedKey};
}

enum MutationKind { reaction, bookmark }

@DataClassName('PendingMutation')
class PendingMutations extends Table {
  TextColumn get kind => textEnum<MutationKind>()();
  TextColumn get articleId =>
      text().references(Articles, #id, onDelete: KeyAction.cascade)();
  BoolColumn get value => boolean()();
  TextColumn get idempotencyKey => text().unique()();
  DateTimeColumn get queuedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {kind, articleId};
}

@DataClassName('KeyValueRow')
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class ContentBlocksConverter extends TypeConverter<List<ContentBlock>, String> {
  const ContentBlocksConverter();

  @override
  List<ContentBlock> fromSql(String fromDb) =>
      ArticleDetailModel.bodyFromJson(jsonDecode(fromDb) as List);

  @override
  String toSql(List<ContentBlock> value) =>
      jsonEncode(ArticleDetailModel.bodyToJson(value));
}

@DriftDatabase(
  tables: [
    Articles,
    ArticleDetails,
    Bookmarks,
    FeedEntries,
    Feeds,
    PendingMutations,
    KeyValues,
  ],
  daos: [ArticlesDao, BookmarksDao, ArticleDetailsDao, FeedDao, OutboxDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
