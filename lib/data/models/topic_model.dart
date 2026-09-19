import '../../domain/entities/topic.dart';

abstract final class TopicModel {
  static Topic fromJson(Map<String, dynamic> json) => Topic(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    icon: json['icon'] as String?,
  );
}
