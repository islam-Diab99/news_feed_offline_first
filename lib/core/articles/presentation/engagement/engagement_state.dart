part of 'engagement_bloc.dart';

class EngagementState extends Equatable {
  const EngagementState({this.notice, this.noticeId = 0});

  final String? notice;
  final int noticeId;

  EngagementState notify(String message) =>
      EngagementState(notice: message, noticeId: noticeId + 1);

  @override
  List<Object?> get props => [notice, noticeId];
}
