import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_detail.dart';
import '../../../domain/repositories/article_repository.dart';

part 'article_detail_event.dart';
part 'article_detail_state.dart';

class ArticleDetailBloc extends Bloc<ArticleDetailEvent, ArticleDetailState> {
  ArticleDetailBloc({required ArticleRepository articleRepository})
    : _repository = articleRepository,
      super(const ArticleDetailInitial()) {
    on<ArticleDetailRequested>(_onRequested, transformer: restartable());
  }

  final ArticleRepository _repository;

  Future<void> _onRequested(
    ArticleDetailRequested event,
    Emitter<ArticleDetailState> emit,
  ) async {
    emit(const ArticleDetailLoading());

    final DetailFetch fetch;
    try {
      fetch = await _repository.fetchDetail(event.articleId);
    } on NetworkException {
      emit(
        const ArticleDetailError(
          'You are offline and this article is not cached.',
          isOffline: true,
        ),
      );
      return;
    } on AppException catch (e) {
      emit(ArticleDetailError(e.message));
      return;
    }

    if (fetch == DetailFetch.unavailable) {
      emit(const ArticleDetailGone());
      return;
    }
    await emit.forEach<ArticleDetailView?>(
      _repository.watchDetail(event.articleId),
      onData: (view) => view == null
          ? const ArticleDetailGone()
          : ArticleDetailLoaded(
              detail: view.detail,
              related: view.related,
              isStale: fetch == DetailFetch.stale,
            ),
    );
  }
}
