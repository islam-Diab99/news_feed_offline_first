import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_update.dart';
import '../../../domain/repositories/bookmark_repository.dart';
import '../../../domain/services/article_update_bus.dart';

part 'bookmarks_event.dart';
part 'bookmarks_state.dart';

class BookmarksBloc extends Bloc<BookmarksEvent, BookmarksState> {
  BookmarksBloc({
    required BookmarkRepository bookmarkRepository,
    required ArticleUpdateBus bus,
  }) : _repository = bookmarkRepository,
       super(const BookmarksState()) {
    on<BookmarksRequested>(_onRequested, transformer: restartable());
    on<_BookmarksArticleUpdated>(_onArticleUpdated, transformer: sequential());

    _busSubscription = bus.stream.listen(
      (update) => add(_BookmarksArticleUpdated(update)),
    );
  }

  final BookmarkRepository _repository;
  late final StreamSubscription<ArticleUpdate> _busSubscription;

  Future<void> _onRequested(
    BookmarksRequested event,
    Emitter<BookmarksState> emit,
  ) async {
    emit(state.copyWith(status: BookmarksStatus.loading));
    try {
      final articles = await _repository.bookmarks();
      emit(state.copyWith(status: BookmarksStatus.success, articles: articles));
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: BookmarksStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  void _onArticleUpdated(
    _BookmarksArticleUpdated event,
    Emitter<BookmarksState> emit,
  ) {
    if (state.status != BookmarksStatus.success) return;
    switch (event.update) {
      case ArticleChanged(:final article):
        final index = state.articles.indexWhere((a) => a.id == article.id);
        if (article.isBookmarked && index == -1) {
          emit(state.copyWith(articles: [article, ...state.articles]));
        } else if (!article.isBookmarked && index != -1) {
          emit(
            state.copyWith(
              articles: state.articles
                  .where((a) => a.id != article.id)
                  .toList(),
            ),
          );
        } else if (index != -1) {
          final articles = [...state.articles]..[index] = article;
          emit(state.copyWith(articles: articles));
        }
      case ArticleRemoved(:final articleId):
        emit(
          state.copyWith(
            articles: state.articles.where((a) => a.id != articleId).toList(),
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _busSubscription.cancel();
    return super.close();
  }
}
