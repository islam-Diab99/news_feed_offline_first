import 'package:drift/drift.dart';

import '../../../../domain/entities/article.dart';
import '../../../../domain/entities/article_detail.dart';
import '../app_database.dart';

part 'article_dao.g.dart';

@DriftAccessor(
  tables: [Articles, ArticleDetails, Bookmarks, FeedEntries, PendingMutations],
)
class ArticleDao extends DatabaseAccessor<AppDatabase> with _$ArticleDaoMixin {
  ArticleDao(super.attachedDatabase);

  late final _queuedReaction = alias(pendingMutations, 'queued_reaction');


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

  Future<void> saveServerDetail(ArticleDetail detail) {
    return transaction(() async {
      await saveServerArticles([detail.article]);
      await into(articleDetails).insertOnConflictUpdate(
        ArticleDetailsCompanion.insert(
          articleId: detail.article.id,
          body: detail.body,
          authorBio: Value(detail.authorBio),
          updatedAt: Value(detail.updatedAt?.toUtc()),
          readTimeMinutes: Value(detail.readTimeMinutes),
          relatedIds: detail.relatedIds,
        ),
      );
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

  Future<void> deleteArticles(Iterable<String> ids) =>
      (delete(articles)..where((a) => a.id.isIn(ids))).go();

  Future<void> setBookmarked(String id, {required bool bookmarked}) async {
    if (bookmarked) {
      await into(bookmarks).insert(
        BookmarksCompanion.insert(articleId: id, savedAt: DateTime.now()),
        mode: InsertMode.insertOrIgnore,
      );
    } else {
      await (delete(bookmarks)..where((b) => b.articleId.equals(id))).go();
    }
  }

  Future<Set<String>> existingIds(Iterable<String> ids) async {
    final query = selectOnly(articles)
      ..addColumns([articles.id])
      ..where(articles.id.isIn(ids));
    return {for (final row in await query.get()) row.read(articles.id)!};
  }

  Future<bool> hasDetail(String id) async {
    final row = await (select(
      articleDetails,
    )..where((d) => d.articleId.equals(id))).getSingleOrNull();
    return row != null;
  }

  Future<Article?> article(String id) =>
      (_select()..where(articles.id.equals(id)))
          .map(_toArticle)
          .getSingleOrNull();

  Future<List<Article>> articlesById(List<String> ids) async =>
      _inOrder(ids, await _byIds(ids).get());

  Stream<List<Article>> watchArticlesById(List<String> ids) =>
      _byIds(ids).watch().map((items) => _inOrder(ids, items));

  Stream<List<Article>> watchFeed(String feedKey) {
    final query =
        _select(
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
    return query.map(_toArticle).watch();
  }

  Stream<List<Article>> watchBookmarks() {
    final query = _select(bookmarkedOnly: true)
      ..orderBy([OrderingTerm.desc(bookmarks.savedAt)]);
    return query.map(_toArticle).watch();
  }

  Stream<ArticleDetail?> watchDetail(String id) {
    final query = _select(
      joins: [
        innerJoin(
          articleDetails,
          articleDetails.articleId.equalsExp(articles.id),
        ),
      ],
    )..where(articles.id.equals(id));
    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      final detail = row.readTable(articleDetails);
      return ArticleDetail(
        article: _toArticle(row),
        body: detail.body,
        authorBio: detail.authorBio,
        updatedAt: detail.updatedAt,
        readTimeMinutes: detail.readTimeMinutes,
        relatedIds: detail.relatedIds,
      );
    });
  }

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

    final select = _select()
      ..where(
        contains(articles.title) |
            contains(articles.summary) |
            contains(articles.tags),
      )
      ..orderBy([OrderingTerm.desc(articles.publishedAt)]);
    if (topicId != null) select.where(articles.topicId.equals(topicId));
    if (source != null) select.where(articles.source.equals(source));
    return select.map(_toArticle).get();
  }

  JoinedSelectStatement<HasResultSet, dynamic> _select({
    List<Join> joins = const [],
    bool bookmarkedOnly = false,
  }) {
    final bookmarkOn = bookmarks.articleId.equalsExp(articles.id);
    return select(articles).join([
      ...joins,
      bookmarkedOnly
          ? innerJoin(bookmarks, bookmarkOn)
          : leftOuterJoin(bookmarks, bookmarkOn),
      leftOuterJoin(
        _queuedReaction,
        _queuedReaction.articleId.equalsExp(articles.id) &
            _queuedReaction.kind.equalsValue(MutationKind.reaction),
      ),
    ]);
  }

  Selectable<Article> _byIds(List<String> ids) =>
      (_select()..where(articles.id.isIn(ids))).map(_toArticle);

  List<Article> _inOrder(List<String> ids, List<Article> items) {
    final byId = {for (final a in items) a.id: a};
    return [for (final id in ids) ?byId[id]];
  }

  /// The single place where server state and local intent meet: a queued
  /// reaction overrides the server's like flag and shifts the count to match.
  Article _toArticle(TypedResult row) {
    final a = row.readTable(articles);
    final queuedLike = row.readTableOrNull(_queuedReaction)?.value;
    final flipped = queuedLike != null && queuedLike != a.isLikedOnServer;
    return Article(
      id: a.id,
      title: a.title,
      summary: a.summary,
      source: a.source,
      authorName: a.authorName,
      authorAvatar: a.authorAvatar,
      topicId: a.topicId,
      publishedAt: a.publishedAt,
      imageUrl: a.imageUrl,
      tags: a.tags,
      likes: !flipped
          ? a.likes
          : queuedLike
          ? a.likes + 1
          : (a.likes > 0 ? a.likes - 1 : 0),
      comments: a.comments,
      isLiked: flipped ? queuedLike : a.isLikedOnServer,
      isBookmarked: row.readTableOrNull(bookmarks) != null,
      version: a.version,
    );
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
