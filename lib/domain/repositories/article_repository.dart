import '../entities/article_detail.dart';

abstract interface class ArticleRepository {
  Future<ArticleDetailResult> detail(String id);
}
