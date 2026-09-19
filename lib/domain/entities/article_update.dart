import 'package:equatable/equatable.dart';

import 'article.dart';

sealed class ArticleUpdate extends Equatable {
  const ArticleUpdate();

  @override
  List<Object?> get props => [];
}

class ArticleChanged extends ArticleUpdate {
  const ArticleChanged(this.article);
  final Article article;

  @override
  List<Object?> get props => [article];
}

class ArticleRemoved extends ArticleUpdate {
  const ArticleRemoved(this.articleId);
  final String articleId;

  @override
  List<Object?> get props => [articleId];
}
