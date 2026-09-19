import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_update.dart';
import '../../../domain/entities/topic.dart';
import '../../../domain/repositories/feed_repository.dart';
import '../../../domain/repositories/search_repository.dart';
import '../../../domain/services/article_update_bus.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required FeedRepository feedRepository,
    required SearchRepository searchRepository,
    required ArticleUpdateBus bus,
  }) : _feed = feedRepository,
       _search = searchRepository,
       super(const FeedState()) {
    on<FeedStarted>(_onStarted, transformer: restartable());
    on<FeedTopicSelected>(_onTopicSelected, transformer: restartable());
    on<FeedNextPageRequested>(_onNextPage, transformer: droppable());
    on<FeedRefreshRequested>(_onRefresh, transformer: droppable());
    on<_FeedArticleUpdated>(_onArticleUpdated, transformer: sequential());

    _busSubscription = bus.stream.listen(
      (update) => add(_FeedArticleUpdated(update)),
    );
  }

  final FeedRepository _feed;
  final SearchRepository _search;
  late final StreamSubscription<ArticleUpdate> _busSubscription;

  Future<void> _onStarted(FeedStarted event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading));

    var topics = state.topics;
    if (topics.isEmpty) {
      try {
        topics = await _search.topics();
      } on AppException {
        topics = const [];
      }
    }

    try {
      final page = await _feed.firstPage(topicId: state.topicId);
      emit(
        state.copyWith(
          status: FeedStatus.success,
          articles: page.items,
          topics: topics,
          nextCursor: page.nextCursor,
          isStale: page.isStale,
          isLoadingMore: false,
          loadMoreFailed: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FeedStatus.failure,
          topics: topics,
          errorMessage: e is NetworkException
              ? 'You are offline and nothing is cached yet.'
              : e.message,
        ),
      );
    }
  }

  Future<void> _onTopicSelected(
    FeedTopicSelected event,
    Emitter<FeedState> emit,
  ) async {
    if (event.topicId == state.topicId) return;
    emit(
      state.copyWith(
        topicId: event.topicId,
        articles: const [],
        nextCursor: null,
      ),
    );
    await _onStarted(const FeedStarted(), emit);
  }

  Future<void> _onNextPage(
    FeedNextPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    final cursor = state.nextCursor;
    if (cursor == null || state.status != FeedStatus.success) return;

    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final page = await _feed.nextPage(cursor, topicId: state.topicId);
      final seen = state.articles.map((a) => a.id).toSet();
      emit(
        state.copyWith(
          articles: [
            ...state.articles,
            ...page.items.where((a) => !seen.contains(a.id)),
          ],
          nextCursor: page.nextCursor,
          isLoadingMore: false,
        ),
      );
    } on AppException {
      emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
    }
  }

  Future<void> _onRefresh(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    try {
      if (state.status != FeedStatus.success) {
        return await _onStarted(const FeedStarted(), emit);
      }
      final result = await _feed.refresh(topicId: state.topicId);
      final head = result.head;
      final headIds = head.items.map((a) => a.id).toSet();
      final deleted = result.deletedIds.toSet();

      final existingIds = state.articles.map((a) => a.id).toSet();
      final newCount = head.items
          .where((a) => !existingIds.contains(a.id))
          .length;

      emit(
        state.copyWith(
          articles: [
            ...head.items,
            ...state.articles.where(
              (a) => !headIds.contains(a.id) && !deleted.contains(a.id),
            ),
          ],
          nextCursor: state.nextCursor ?? head.nextCursor,
          isStale: false,
          notice: newCount > 0
              ? '$newCount new ${newCount == 1 ? 'story' : 'stories'}'
              : null,
        ),
      );
    } on NetworkException {
      emit(
        state.copyWith(
          isStale: true,
          notice: 'You are offline — showing saved stories.',
        ),
      );
    } on AppException {
      emit(state.copyWith(notice: 'Could not refresh. Pull to try again.'));
    } finally {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  void _onArticleUpdated(_FeedArticleUpdated event, Emitter<FeedState> emit) {
    switch (event.update) {
      case ArticleChanged(:final article):
        final index = state.articles.indexWhere((a) => a.id == article.id);
        if (index == -1) return;
        final articles = [...state.articles]..[index] = article;
        emit(state.copyWith(articles: articles));
      case ArticleRemoved(:final articleId):
        final articles = state.articles
            .where((a) => a.id != articleId)
            .toList();
        if (articles.length == state.articles.length) return;
        emit(state.copyWith(articles: articles));
    }
  }

  @override
  Future<void> close() async {
    await _busSubscription.cancel();
    return super.close();
  }
}
