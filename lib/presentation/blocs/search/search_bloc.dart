import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/bloc_transformers.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/topic.dart';
import '../../../domain/repositories/article_repository.dart';
import '../../../domain/repositories/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchRepository searchRepository,
    required ArticleRepository articleRepository,
    Duration debounce = const Duration(milliseconds: 400),
  }) : _repository = searchRepository,
       _articles = articleRepository,
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
    on<_SearchResultsShown>(_onResultsShown, transformer: restartable());
  }

  final SearchRepository _repository;
  final ArticleRepository _articles;

  /// Bumped whenever a new result list is shown, so a watcher still bound to
  /// an older list can never write its rows back over the newer one.
  int _resultsGeneration = 0;

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
      _showResults(
        emit,
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

  /// Both filters reset in one handler so the reset costs a single search
  /// instead of one per axis.
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
      _showResults(
        emit,
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

    final nextPage = int.tryParse(cursor.split('_').last);
    if (nextPage == null) return;

    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final page = await _repository.search(
        state.query,
        topicId: state.topicId,
        source: state.source,
        page: nextPage,
      );
      final seen = state.results.map((a) => a.id).toSet();
      _showResults(
        emit,
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

  void _showResults(Emitter<SearchState> emit, SearchState next) {
    if (emit.isDone) return;
    emit(next);
    add(
      _SearchResultsShown(++_resultsGeneration, [
        for (final a in next.results) a.id,
      ]),
    );
  }

  Future<void> _onResultsShown(
    _SearchResultsShown event,
    Emitter<SearchState> emit,
  ) async {
    if (event.ids.isEmpty) return;
    await emit.forEach<List<Article>>(
      _articles.watchArticles(event.ids),
      onData: (results) => event.generation == _resultsGeneration
          ? state.copyWith(results: results)
          : state,
    );
  }
}
