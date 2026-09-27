import '../entities/article.dart';

abstract interface class BookmarkRepository {
  Stream<List<Article>> watchBookmarks();

  Future<void> toggle(Article article);
}
