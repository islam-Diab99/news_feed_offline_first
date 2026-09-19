part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.articles = const [],
    this.topics = const [],
    this.topicNames = const {},
    this.topicId,
    this.nextCursor,
    this.isStale = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.notice,
    this.noticeId = 0,
  });

  final FeedStatus status;
  final List<Article> articles;
  final List<Topic> topics;

  /// Derived from [topics] in [copyWith] so consumers get a stable map
  /// instance instead of one rebuilt on every widget build.
  final Map<String, String> topicNames;
  final String? topicId;
  final String? nextCursor;

  final bool isStale;

  final bool isLoadingMore;
  final bool loadMoreFailed;

  final bool isRefreshing;

  final String? errorMessage;

  final String? notice;
  final int noticeId;

  bool get hasMore => nextCursor != null;
  bool get isEmpty => status == FeedStatus.success && articles.isEmpty;

  FeedState copyWith({
    FeedStatus? status,
    List<Article>? articles,
    List<Topic>? topics,
    Object? topicId = _unset,
    Object? nextCursor = _unset,
    bool? isStale,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    bool? isRefreshing,
    String? errorMessage,
    String? notice,
  }) {
    return FeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      topics: topics ?? this.topics,
      topicNames: topics == null
          ? topicNames
          : {for (final t in topics) t.id: t.name},
      topicId: topicId == _unset ? this.topicId : topicId as String?,
      nextCursor: nextCursor == _unset
          ? this.nextCursor
          : nextCursor as String?,
      isStale: isStale ?? this.isStale,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      notice: notice,
      noticeId: notice != null ? noticeId + 1 : noticeId,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [
    status,
    articles,
    topics,
    topicId,
    nextCursor,
    isStale,
    isLoadingMore,
    loadMoreFailed,
    isRefreshing,
    errorMessage,
    notice,
    noticeId,
  ];
}
