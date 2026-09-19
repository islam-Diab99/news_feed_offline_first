part of 'article_detail_bloc.dart';

sealed class ArticleDetailState extends Equatable {
  const ArticleDetailState();

  @override
  List<Object?> get props => [];
}

class ArticleDetailInitial extends ArticleDetailState {
  const ArticleDetailInitial();
}

class ArticleDetailLoading extends ArticleDetailState {
  const ArticleDetailLoading();
}

class ArticleDetailLoaded extends ArticleDetailState {
  const ArticleDetailLoaded({
    required this.detail,
    this.related = const [],
    this.isStale = false,
  });

  final ArticleDetail detail;
  final List<Article> related;
  final bool isStale;

  ArticleDetailLoaded copyWith({
    ArticleDetail? detail,
    List<Article>? related,
  }) => ArticleDetailLoaded(
    detail: detail ?? this.detail,
    related: related ?? this.related,
    isStale: isStale,
  );

  @override
  List<Object?> get props => [detail, related, isStale];
}

class ArticleDetailGone extends ArticleDetailState {
  const ArticleDetailGone({this.reason});
  final String? reason;

  @override
  List<Object?> get props => [reason];
}

class ArticleDetailError extends ArticleDetailState {
  const ArticleDetailError(this.message, {this.isOffline = false});
  final String message;
  final bool isOffline;

  @override
  List<Object?> get props => [message, isOffline];
}
