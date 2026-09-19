part of 'engagement_bloc.dart';

sealed class EngagementEvent extends Equatable {
  const EngagementEvent();

  @override
  List<Object?> get props => [];
}

class EngagementLikeToggled extends EngagementEvent {
  const EngagementLikeToggled(this.article);
  final Article article;

  @override
  List<Object?> get props => [article];
}

class EngagementBookmarkToggled extends EngagementEvent {
  const EngagementBookmarkToggled(this.article);
  final Article article;

  @override
  List<Object?> get props => [article];
}
