import 'package:drift/drift.dart';

import '../../../../domain/entities/article_detail.dart';
import '../app_database.dart';
import '../article_read_model.dart';

part 'article_details_dao.g.dart';

/// Owns [ArticleDetails]: the body and metadata only the detail endpoint
/// returns. The article itself is joined in, so a like elsewhere shows here.
@DriftAccessor(tables: [ArticleDetails, Articles, Bookmarks, PendingMutations])
class ArticleDetailsDao extends DatabaseAccessor<AppDatabase>
    with _$ArticleDetailsDaoMixin, ArticleReadModel {
  ArticleDetailsDao(super.attachedDatabase);

  /// Stores the detail part; the article row must already exist, since the
  /// detail references it.
  Future<void> saveDetail(ArticleDetail detail) =>
      into(articleDetails).insertOnConflictUpdate(
        ArticleDetailsCompanion.insert(
          articleId: detail.article.id,
          body: detail.body,
          authorBio: Value(detail.authorBio),
          updatedAt: Value(detail.updatedAt?.toUtc()),
          readTimeMinutes: Value(detail.readTimeMinutes),
          relatedIds: detail.relatedIds,
        ),
      );

  Future<bool> hasDetail(String id) async {
    final row = await (select(
      articleDetails,
    )..where((d) => d.articleId.equals(id))).getSingleOrNull();
    return row != null;
  }

  Stream<ArticleDetail?> watchDetail(String id) {
    final query = selectArticles(
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
        article: readArticle(row),
        body: detail.body,
        authorBio: detail.authorBio,
        updatedAt: detail.updatedAt,
        readTimeMinutes: detail.readTimeMinutes,
        relatedIds: detail.relatedIds,
      );
    });
  }
}
