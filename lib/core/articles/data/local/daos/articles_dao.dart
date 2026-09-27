import 'package:drift/drift.dart';

import '../../../domain/entities/article.dart';
import '../app_database.dart';
import '../article_read_model.dart';

part 'articles_dao.g.dart';

/// Writes the server-owned [Articles] table. Reads join bookmarks and the
/// outbox through [ArticleReadModel]; this DAO never writes those tables.
@DriftAccessor(tables: [Articles, Bookmarks, PendingMutations])
class ArticlesDao extends DatabaseAccessor<AppDatabase>
    with _$ArticlesDaoMixin, ArticleReadModel {
  ArticlesDao(super.attachedDatabase);

  /// Upserts server payloads, skipping any that are older than what is
  /// already stored (an in-flight response must not undo a newer write).
  Future<void> saveServerArticles(Iterable<Article> items) {
    return batch((b) {
      for (final article in items) {
        final row = _toRow(article);
        b.insert(
          articles,
          row,
          onConflict: DoUpdate<$ArticlesTable, ArticleRow>(
            (_) => row,
            where: (old) => old.version.isSmallerOrEqualValue(article.version),
          ),
        );
      }
    });
  }

  Future<void> setServerReaction(
    String id, {
    required bool isLiked,
    required int likes,
    required int version,
  }) {
    return (update(articles)..where((a) => a.id.equals(id))).write(
      ArticlesCompanion(
        isLikedOnServer: Value(isLiked),
        likes: Value(likes),
        version: Value(version),
      ),
    );
  }

  /// Folds a reaction the server accepted through `/sync` into the stored
  /// row. Guarded on the old flag so replaying it twice cannot double-count.
  Future<void> confirmReaction(String id, {required bool liked}) {
    final likes = liked
        ? articles.likes + const Constant(1)
        : FunctionCallExpression<int>('max', [
            articles.likes - const Constant(1),
            const Constant(0),
          ]);
    return (update(
      articles,
    )..where((a) => a.id.equals(id) & a.isLikedOnServer.equals(!liked))).write(
      ArticlesCompanion.custom(isLikedOnServer: Constant(liked), likes: likes),
    );
  }

  /// Foreign keys cascade the delete into feeds, bookmarks, details and any
  /// queued mutation for these articles.
  Future<void> deleteArticles(Iterable<String> ids) =>
      (delete(articles)..where((a) => a.id.isIn(ids))).go();

  Future<Set<String>> existingIds(Iterable<String> ids) async {
    final query = selectOnly(articles)
      ..addColumns([articles.id])
      ..where(articles.id.isIn(ids));
    return {for (final row in await query.get()) row.read(articles.id)!};
  }

  Future<Article?> article(String id) =>
      (selectArticles()..where(articles.id.equals(id)))
          .map(readArticle)
          .getSingleOrNull();

  Future<List<Article>> articlesById(List<String> ids) async =>
      _inOrder(ids, await _byIds(ids).get());

  Stream<List<Article>> watchArticlesById(List<String> ids) =>
      _byIds(ids).watch().map((items) => _inOrder(ids, items));

  Future<List<Article>> searchCached(
    String query, {
    String? topicId,
    String? source,
  }) {
    final needle = Variable.withString(query.trim().toLowerCase());
    Expression<bool> contains(Expression<String> column) =>
        FunctionCallExpression<int>('instr', [
          column.lower(),
          needle,
        ]).isBiggerThanValue(0);

    final select = selectArticles()
      ..where(
        contains(articles.title) |
            contains(articles.summary) |
            contains(articles.tags),
      )
      ..orderBy([OrderingTerm.desc(articles.publishedAt)]);
    if (topicId != null) select.where(articles.topicId.equals(topicId));
    if (source != null) select.where(articles.source.equals(source));
    return select.map(readArticle).get();
  }

  Selectable<Article> _byIds(List<String> ids) =>
      (selectArticles()..where(articles.id.isIn(ids))).map(readArticle);

  List<Article> _inOrder(List<String> ids, List<Article> items) {
    final byId = {for (final a in items) a.id: a};
    return [for (final id in ids) ?byId[id]];
  }

  ArticlesCompanion _toRow(Article a) => ArticlesCompanion.insert(
    id: a.id,
    title: a.title,
    summary: a.summary,
    source: a.source,
    authorName: a.authorName,
    authorAvatar: Value(a.authorAvatar),
    topicId: a.topicId,
    // Stored as ISO-8601 text; a single time zone keeps text order == time order.
    publishedAt: a.publishedAt.toUtc(),
    imageUrl: Value(a.imageUrl),
    tags: a.tags,
    likes: a.likes,
    comments: a.comments,
    isLikedOnServer: a.isLiked,
    version: a.version,
  );
}
