part of 'article_detail_bloc.dart';

sealed class ArticleDetailEvent extends Equatable {
  const ArticleDetailEvent();

  @override
  List<Object?> get props => [];
}

class ArticleDetailRequested extends ArticleDetailEvent {
  const ArticleDetailRequested(this.articleId);
  final String articleId;

  @override
  List<Object?> get props => [articleId];
}

class _ArticleDetailArticleUpdated extends ArticleDetailEvent {
  const _ArticleDetailArticleUpdated(this.update);
  final ArticleUpdate update;

  @override
  List<Object?> get props => [update];
}
