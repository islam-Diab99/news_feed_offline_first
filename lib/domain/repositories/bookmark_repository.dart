import '../entities/article.dart';

abstract interface class BookmarkRepository {
  Future<List<Article>> bookmarks();

  Future<void> toggle(Article article);
}
