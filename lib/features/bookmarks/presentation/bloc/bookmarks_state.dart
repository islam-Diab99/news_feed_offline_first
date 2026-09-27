part of 'bookmarks_bloc.dart';

enum BookmarksStatus { initial, loading, success, failure }

class BookmarksState extends Equatable {
  const BookmarksState({
    this.status = BookmarksStatus.initial,
    this.articles = const [],
    this.errorMessage,
  });

  final BookmarksStatus status;
  final List<Article> articles;
  final String? errorMessage;

  bool get isEmpty => status == BookmarksStatus.success && articles.isEmpty;

  BookmarksState copyWith({
    BookmarksStatus? status,
    List<Article>? articles,
    String? errorMessage,
  }) => BookmarksState(
    status: status ?? this.status,
    articles: articles ?? this.articles,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, articles, errorMessage];
}
