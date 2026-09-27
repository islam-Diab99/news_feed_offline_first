part of 'search_bloc.dart';

enum SearchStatus { idle, loading, success, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.topicId,
    this.source,
    this.results = const [],
    this.nextCursor,
    this.total,
    this.isStale = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.topics = const [],
    this.sources = const [],
    this.errorMessage,
  });

  final SearchStatus status;
  final String query;
  final String? topicId;
  final String? source;
  final List<Article> results;
  final String? nextCursor;
  final int? total;
  final bool isStale;
  final bool isLoadingMore;

  final bool loadMoreFailed;

  final List<Topic> topics;
  final List<String> sources;
  final String? errorMessage;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get isEmpty =>
      status == SearchStatus.success && hasQuery && results.isEmpty;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    Object? topicId = _unset,
    Object? source = _unset,
    List<Article>? results,
    Object? nextCursor = _unset,
    int? total,
    bool? isStale,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    List<Topic>? topics,
    List<String>? sources,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      topicId: topicId == _unset ? this.topicId : topicId as String?,
      source: source == _unset ? this.source : source as String?,
      results: results ?? this.results,
      nextCursor: nextCursor == _unset
          ? this.nextCursor
          : nextCursor as String?,
      total: total ?? this.total,
      isStale: isStale ?? this.isStale,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      topics: topics ?? this.topics,
      sources: sources ?? this.sources,
      errorMessage: errorMessage,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [
    status,
    query,
    topicId,
    source,
    results,
    nextCursor,
    total,
    isStale,
    isLoadingMore,
    loadMoreFailed,
    topics,
    sources,
    errorMessage,
  ];
}
