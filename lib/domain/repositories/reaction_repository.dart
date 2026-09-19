import '../entities/article.dart';

abstract interface class ReactionRepository {
  Future<void> toggleLike(Article article);
}
