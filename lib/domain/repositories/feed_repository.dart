import 'package:equatable/equatable.dart';

import '../entities/article.dart';

class FeedLoadResult extends Equatable {
  const FeedLoadResult({required this.hasMore, this.isStale = false});

  final bool hasMore;
  final bool isStale;

  @override
  List<Object?> get props => [hasMore, isStale];
}

class FeedRefreshResult extends Equatable {
  const FeedRefreshResult({required this.newStories});

  final int newStories;

  @override
  List<Object?> get props => [newStories];
}

/// Loads write into the local store; [watchFeed] is the only read path, so
/// every screen sees the same data no matter which call changed it.
abstract interface class FeedRepository {
  Stream<List<Article>> watchFeed({String? topicId, String? source});

  Future<FeedLoadResult> loadFirstPage({String? topicId, String? source});

  Future<FeedLoadResult> loadNextPage({String? topicId, String? source});

  Future<FeedRefreshResult> refresh({String? topicId, String? source});
}
