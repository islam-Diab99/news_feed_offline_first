part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedStarted extends FeedEvent {
  const FeedStarted();
}

class FeedTopicSelected extends FeedEvent {
  const FeedTopicSelected(this.topicId);
  final String? topicId;

  @override
  List<Object?> get props => [topicId];
}

class FeedNextPageRequested extends FeedEvent {
  const FeedNextPageRequested();
}

class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}

class _FeedArticleUpdated extends FeedEvent {
  const _FeedArticleUpdated(this.update);
  final ArticleUpdate update;

  @override
  List<Object?> get props => [update];
}
