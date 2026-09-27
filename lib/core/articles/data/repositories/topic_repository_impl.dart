import '../../../error/app_exception.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/topic_repository.dart';
import '../remote/api_client.dart';

class TopicRepositoryImpl implements TopicRepository {
  TopicRepositoryImpl({required ApiClient api}) : _api = api;

  final ApiClient _api;

  List<Topic>? _topics;
  final Map<String, List<String>> _sources = {};

  @override
  Future<List<Topic>> topics() async {
    if (_topics != null) return _topics!;
    try {
      return _topics = await _api.getTopics();
    } on NetworkException {
      return const [];
    }
  }

  @override
  Future<List<String>> sources({String? topicId}) async {
    final key = topicId ?? '*';
    if (_sources.containsKey(key)) return _sources[key]!;
    try {
      return _sources[key] = await _api.getSources(topicId: topicId);
    } on NetworkException {
      return const [];
    }
  }
}
