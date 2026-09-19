part of 'bookmarks_bloc.dart';

sealed class BookmarksEvent extends Equatable {
  const BookmarksEvent();

  @override
  List<Object?> get props => [];
}

class BookmarksRequested extends BookmarksEvent {
  const BookmarksRequested();
}

class _BookmarksArticleUpdated extends BookmarksEvent {
  const _BookmarksArticleUpdated(this.update);
  final ArticleUpdate update;

  @override
  List<Object?> get props => [update];
}
