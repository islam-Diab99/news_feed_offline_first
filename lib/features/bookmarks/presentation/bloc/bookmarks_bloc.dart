import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/articles/domain/entities/article.dart';
import '../../../../core/articles/domain/repositories/bookmark_repository.dart';

part 'bookmarks_event.dart';
part 'bookmarks_state.dart';

class BookmarksBloc extends Bloc<BookmarksEvent, BookmarksState> {
  BookmarksBloc({required BookmarkRepository bookmarkRepository})
    : _repository = bookmarkRepository,
      super(const BookmarksState()) {
    on<BookmarksRequested>(_onRequested, transformer: restartable());
  }

  final BookmarkRepository _repository;

  Future<void> _onRequested(
    BookmarksRequested event,
    Emitter<BookmarksState> emit,
  ) async {
    emit(state.copyWith(status: BookmarksStatus.loading));
    await emit.forEach<List<Article>>(
      _repository.watchBookmarks(),
      onData: (articles) =>
          state.copyWith(status: BookmarksStatus.success, articles: articles),
      onError: (_, _) => state.copyWith(
        status: BookmarksStatus.failure,
        errorMessage: 'Could not load bookmarks.',
      ),
    );
  }
}
