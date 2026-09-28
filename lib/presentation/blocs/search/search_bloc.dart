import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/bloc_transformers.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_update.dart';
import '../../../domain/entities/topic.dart';
import '../../../domain/repositories/search_repository.dart';
import '../../../domain/services/article_update_bus.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchRepository searchRepository,
    required ArticleUpdateBus bus,
    Duration debounce = const Duration(milliseconds: 400),
  }) : _repository = searchRepository,
       super(const SearchState()) {
    on<SearchStarted>(_onStarted);
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceRestartable(debounce),
    );
    on<SearchTopicFilterChanged>(_onTopicChanged, transformer: restartable());
    on<SearchSourceFilterChanged>(_onSourceChanged, transformer: restartable());
    on<SearchFiltersCleared>(_onFiltersCleared, transformer: restartable());
    on<SearchRetryRequested>(_onRetry, transformer: restartable());
    on<SearchNextPageRequested>(_onNextPage, transformer: droppable());
    on<_SearchArticleUpdated>(_onArticleUpdated, transformer: sequential());

    _busSubscription = bus.stream.listen(
      (update) => add(_SearchArticleUpdated(update)),
    );
  }

  final SearchRepository _repository;
  late final StreamSubscription<ArticleUpdate> _busSubscription;

  Future<void> _onStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final topics = await _repository.topics();
      final sources = await _repository.sources();
      emit(state.copyWith(topics: topics, sources: sources));
    } on AppException catch (_) {}
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          status: SearchStatus.idle,
          query: '',
          results: const [],
          nextCursor: null,
          isStale: false,
        ),
      );
      return;
    }
    await _execute(query, emit);
  }

  Future<void> _onTopicChanged(
    SearchTopicFilterChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.topicId == state.topicId) return;
    List<String> sources;
    try {
      sources = await _repository.sources(topicId: event.topicId);
    } on AppException {
      sources = const [];
    }
    final keepSource = state.source != null && sources.contains(state.source);
    emit(
      state.copyWith(
        topicId: event.topicId,
        source: keepSource ? state.source : null,
        sources: sources,
      ),
    );
    if (state.hasQuery) await _execute(state.query, emit);
  }

  Future<void> _onSourceChanged(
    SearchSourceFilterChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(source: event.source));
    if (state.hasQuery) await _execute(state.query, emit);
  }

  Future<void> _onFiltersCleared(
    SearchFiltersCleared event,
    Emitter<SearchState> emit,
  ) async {
    if (state.topicId == null && state.source == null) return;
    List<String> sources;
    try {
      sources = await _repository.sources();
    } on AppException {
      sources = state.sources;
    }
    emit(state.copyWith(topicId: null, source: null, sources: sources));
    if (state.hasQuery) await _execute(state.query, emit);
  }

  Future<void> _onRetry(
    SearchRetryRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (state.hasQuery) await _execute(state.query, emit);
  }

  Future<void> _execute(String query, Emitter<SearchState> emit) async {
    emit(state.copyWith(status: SearchStatus.loading, query: query));
    try {
      final page = await _repository.search(
        query,
        topicId: state.topicId,
        source: state.source,
      );
      emit(
        state.copyWith(
          status: SearchStatus.success,
          results: page.items,
          nextCursor: page.nextCursor,
          total: page.total,
          isStale: page.isStale,
          loadMoreFailed: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: SearchStatus.failure, errorMessage: e.message),
      );
    }
  }

  Future<void> _onNextPage(
    SearchNextPageRequested event,
    Emitter<SearchState> emit,
  ) async {
    final cursor = state.nextCursor;
    if (cursor == null || state.status != SearchStatus.success) return;

    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final page = await _repository.search(
        state.query,
        topicId: state.topicId,
        source: state.source,
        cursor: cursor,
      );
      final seen = state.results.map((a) => a.id).toSet();
      emit(
        state.copyWith(
          results: [
            ...state.results,
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

  void _onArticleUpdated(
    _SearchArticleUpdated event,
    Emitter<SearchState> emit,
  ) {
    switch (event.update) {
      case ArticleChanged(:final article):
        final index = state.results.indexWhere((a) => a.id == article.id);
        if (index == -1) return;
        final results = [...state.results]..[index] = article;
        emit(state.copyWith(results: results));
      case ArticleRemoved(:final articleId):
        final results = state.results.where((a) => a.id != articleId).toList();
        if (results.length == state.results.length) return;
        emit(state.copyWith(results: results));
    }
  }

  @override
  Future<void> close() async {
    await _busSubscription.cancel();
    return super.close();
  }
}
