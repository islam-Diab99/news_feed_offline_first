import 'package:drift/drift.dart';

import '../../../../domain/entities/article.dart';
import '../app_database.dart';
import '../article_read_model.dart';

part 'bookmarks_dao.g.dart';

/// Owns [Bookmarks]. Listing bookmarked articles is one JOIN against
/// [Articles], so this DAO needs the table, not the articles DAO.
@DriftAccessor(tables: [Bookmarks, Articles, PendingMutations])
class BookmarksDao extends DatabaseAccessor<AppDatabase>
    with _$BookmarksDaoMixin, ArticleReadModel {
  BookmarksDao(super.attachedDatabase);

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

  Stream<List<Article>> watchBookmarks() {
    final query = selectArticles(bookmarkedOnly: true)
      ..orderBy([OrderingTerm.desc(bookmarks.savedAt)]);
    return query.map(readArticle).watch();
  }
}
