import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/topic.dart';
import '../../../domain/repositories/feed_repository.dart';
import '../../../domain/repositories/search_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required FeedRepository feedRepository,
    required SearchRepository searchRepository,
  }) : _feed = feedRepository,
       _search = searchRepository,
       super(const FeedState()) {
    on<FeedStarted>(_onStarted, transformer: restartable());
    on<FeedTopicSelected>(_onTopicSelected);
    on<FeedNextPageRequested>(_onNextPage, transformer: droppable());
    on<FeedRefreshRequested>(_onRefresh, transformer: droppable());
  }

  final FeedRepository _feed;
  final SearchRepository _search;

  Future<void> refresh() {
    final done = stream.firstWhere((s) => !s.isRefreshing);
    add(const FeedRefreshRequested());
    return done;
  }

  /// Loads page 1, then follows the stored feed for as long as this filter is
  /// active. Every later write — pages, refreshes, likes, bookmarks, sync —
  /// reaches the list through that one subscription.
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

    final topicId = state.topicId;
    final FeedLoadResult result;
    try {
      result = await _feed.loadFirstPage(topicId: topicId);
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
      return;
    }

    emit(
      state.copyWith(
        topics: topics,
        hasMore: result.hasMore,
        isStale: result.isStale,
        isLoadingMore: false,
        loadMoreFailed: false,
      ),
    );
    await emit.forEach<List<Article>>(
      _feed.watchFeed(topicId: topicId),
      onData: (articles) => state.topicId != topicId
          ? state
          : state.copyWith(status: FeedStatus.success, articles: articles),
    );
  }

  void _onTopicSelected(FeedTopicSelected event, Emitter<FeedState> emit) {
    if (event.topicId == state.topicId) return;
    emit(
      state.copyWith(
        topicId: event.topicId,
        articles: const [],
        hasMore: false,
      ),
    );
    add(const FeedStarted());
  }

  Future<void> _onNextPage(
    FeedNextPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (!state.hasMore || state.status != FeedStatus.success) return;

    final topicId = state.topicId;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final result = await _feed.loadNextPage(topicId: topicId);
      if (state.topicId != topicId) return;
      emit(state.copyWith(hasMore: result.hasMore, isLoadingMore: false));
    } on AppException {
      emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
    }
  }

  Future<void> _onRefresh(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.status != FeedStatus.success) {
      add(const FeedStarted());
      return;
    }
    emit(state.copyWith(isRefreshing: true));
    try {
      final result = await _feed.refresh(topicId: state.topicId);
      final count = result.newStories;
      emit(
        state.copyWith(
          isStale: false,
          notice: count > 0
              ? '$count new ${count == 1 ? 'story' : 'stories'}'
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
}
