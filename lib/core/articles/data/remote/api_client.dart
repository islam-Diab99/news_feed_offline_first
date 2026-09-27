import '../../domain/entities/article.dart';
import '../../domain/entities/article_detail.dart';
import '../../domain/entities/topic.dart';
import '../models/outbox_mutation.dart';

class FeedPageResponse {
  const FeedPageResponse({
    required this.items,
    required this.page,
    required this.total,
    this.nextCursor,
  });

  final List<Article> items;
  final int page;
  final int total;
  final String? nextCursor;
}

sealed class ArticleDetailResponse {
  const ArticleDetailResponse();
}

class ArticleDetailData extends ArticleDetailResponse {
  const ArticleDetailData(this.detail);
  final ArticleDetail detail;
}

class ArticleUnavailable extends ArticleDetailResponse {
  const ArticleUnavailable(this.articleId, {this.reason});
  final String articleId;
  final String? reason;
}

sealed class ReactionResponse {
  const ReactionResponse();
}

class ReactionSuccess extends ReactionResponse {
  const ReactionSuccess({required this.likes, required this.version});
  final int likes;
  final int version;
}

class ReactionConflict extends ReactionResponse {
  const ReactionConflict({
    required this.isLiked,
    required this.likes,
    required this.version,
  });
  final bool isLiked;
  final int likes;
  final int version;
}

class FeedUpdatesResponse {
  const FeedUpdatesResponse({
    this.newItems = const [],
    this.updatedItems = const [],
    this.deletedItems = const [],
    required this.serverTime,
  });

  final List<String> newItems;
  final List<String> updatedItems;
  final List<String> deletedItems;
  final DateTime serverTime;
}

class SyncResponse {
  const SyncResponse({this.applied = const [], this.conflicts = const []});

  final List<String> applied;

  final List<Article> conflicts;
}

abstract interface class ApiClient {
  Future<List<Topic>> getTopics();

  Future<List<String>> getSources({String? topicId});

  Future<FeedPageResponse> getFeed({
    int page = 1,
    String? cursor,
    int pageSize,
    String? topicId,
    String? source,
  });

  Future<FeedUpdatesResponse> getFeedUpdates(DateTime since);

  Future<ArticleDetailResponse> getArticle(String id);

  Future<FeedPageResponse> search(
    String query, {
    int page = 1,
    int pageSize,
    String? topicId,
    String? source,
  });

  Future<ReactionResponse> setReaction(
    String articleId, {
    required bool liked,
    required String clientMutationId,
    required int expectedVersion,
  });

  Future<void> setBookmark(String articleId, {required bool bookmarked});

  Future<SyncResponse> sync(List<OutboxMutation> mutations);
}
