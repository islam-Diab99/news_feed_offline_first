import '../entities/article.dart';
import '../entities/article_detail.dart';

abstract interface class ArticleRepository {
  Future<DetailFetch> fetchDetail(String id);


  Stream<ArticleDetailView?> watchDetail(String id);

  Stream<List<Article>> watchArticles(List<String> ids);
}
