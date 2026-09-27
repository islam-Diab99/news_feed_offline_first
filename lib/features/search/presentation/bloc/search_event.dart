part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchStarted extends SearchEvent {
  const SearchStarted();
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchTopicFilterChanged extends SearchEvent {
  const SearchTopicFilterChanged(this.topicId);
  final String? topicId;

  @override
  List<Object?> get props => [topicId];
}

class SearchSourceFilterChanged extends SearchEvent {
  const SearchSourceFilterChanged(this.source);
  final String? source;

  @override
  List<Object?> get props => [source];
}

class SearchFiltersCleared extends SearchEvent {
  const SearchFiltersCleared();
}

class SearchNextPageRequested extends SearchEvent {
  const SearchNextPageRequested();
}

class SearchRetryRequested extends SearchEvent {
  const SearchRetryRequested();
}

class _SearchResultsShown extends SearchEvent {
  const _SearchResultsShown(this.generation, this.ids);
  final int generation;
  final List<String> ids;

  @override
  List<Object?> get props => [generation, ids];
}
