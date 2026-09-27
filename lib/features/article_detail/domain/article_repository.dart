import '../../../core/articles/domain/entities/article_detail.dart';

abstract interface class ArticleRepository {
  Future<DetailFetch> fetchDetail(String id);

  Stream<ArticleDetailView?> watchDetail(String id);
}
