import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_detail.dart';
import '../../../domain/entities/article_update.dart';
import '../../../domain/repositories/article_repository.dart';
import '../../../domain/services/article_update_bus.dart';

part 'article_detail_event.dart';
part 'article_detail_state.dart';

class ArticleDetailBloc extends Bloc<ArticleDetailEvent, ArticleDetailState> {
  ArticleDetailBloc({
    required ArticleRepository articleRepository,
    required ArticleUpdateBus bus,
  }) : _repository = articleRepository,
       super(const ArticleDetailInitial()) {
    on<ArticleDetailRequested>(_onRequested, transformer: restartable());
    on<_ArticleDetailArticleUpdated>(
      _onArticleUpdated,
      transformer: sequential(),
    );

    _busSubscription = bus.stream.listen(
      (update) => add(_ArticleDetailArticleUpdated(update)),
    );
  }

  final ArticleRepository _repository;
  late final StreamSubscription<ArticleUpdate> _busSubscription;

  Future<void> _onRequested(
    ArticleDetailRequested event,
    Emitter<ArticleDetailState> emit,
  ) async {
    emit(const ArticleDetailLoading());
    try {
      final result = await _repository.detail(event.articleId);
      switch (result) {
        case ArticleDetailAvailable(
          :final detail,
          :final related,
          :final isStale,
        ):
          emit(
            ArticleDetailLoaded(
              detail: detail,
              related: related,
              isStale: isStale,
            ),
          );
        case ArticleDetailUnavailable(:final reason):
          emit(ArticleDetailGone(reason: reason));
      }
    } on NetworkException {
      emit(
        const ArticleDetailError(
          'You are offline and this article is not cached.',
          isOffline: true,
        ),
      );
    } on AppException catch (e) {
      emit(ArticleDetailError(e.message));
    }
  }

  void _onArticleUpdated(
    _ArticleDetailArticleUpdated event,
    Emitter<ArticleDetailState> emit,
  ) {
    final current = state;
    if (current is! ArticleDetailLoaded) return;

    switch (event.update) {
      case ArticleChanged(:final article):
        if (article.id == current.detail.article.id) {
          emit(current.copyWith(detail: current.detail.withArticle(article)));
        } else {
          final index = current.related.indexWhere((a) => a.id == article.id);
          if (index == -1) return;
          final related = [...current.related]..[index] = article;
          emit(current.copyWith(related: related));
        }
      case ArticleRemoved(:final articleId):
        if (articleId == current.detail.article.id) {
          emit(const ArticleDetailGone(reason: 'removed_by_publisher'));
        }
    }
  }

  @override
  Future<void> close() async {
    await _busSubscription.cancel();
    return super.close();
  }
}
