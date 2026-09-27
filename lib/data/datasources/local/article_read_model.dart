import 'package:drift/drift.dart';

import '../../../domain/entities/article.dart';
import 'app_database.dart';

/// How every DAO reads an [Article]: the server row joined with the user's
/// local intent (bookmark row, queued reaction). The composition happens in
/// SQL, so a DAO that lists articles needs the tables, never another DAO.
mixin ArticleReadModel on DatabaseAccessor<AppDatabase> {
  late final _queuedReaction = alias(
    attachedDatabase.pendingMutations,
    'queued_reaction',
  );

  /// Selects articles with local state attached. [joins] narrow the rows
  /// (a feed, a detail); [bookmarkedOnly] turns the bookmark join inner.
  JoinedSelectStatement<HasResultSet, dynamic> selectArticles({
    List<Join> joins = const [],
    bool bookmarkedOnly = false,
  }) {
    final articles = attachedDatabase.articles;
    final bookmarks = attachedDatabase.bookmarks;
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

  /// The single place where server state and local intent meet: a queued
  /// reaction overrides the server's like flag and shifts the count to match.
  Article readArticle(TypedResult row) {
    final a = row.readTable(attachedDatabase.articles);
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
      isBookmarked: row.readTableOrNull(attachedDatabase.bookmarks) != null,
      version: a.version,
    );
  }
}
