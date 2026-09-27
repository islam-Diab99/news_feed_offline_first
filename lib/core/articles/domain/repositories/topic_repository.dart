import '../entities/topic.dart';

/// The filter catalog (topics and sources) that both the feed and search use.
abstract interface class TopicRepository {
  Future<List<Topic>> topics();

  Future<List<String>> sources({String? topicId});
}
