import '../../core/error/app_exception.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/reaction_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/api_client.dart';


class ReactionRepositoryImpl implements ReactionRepository {
  ReactionRepositoryImpl({
    required ApiClient api,
    required AppDatabase db,
    required ConnectivityService connectivity,
  }) : _api = api,
       _db = db,
       _connectivity = connectivity;

  final ApiClient _api;
  final AppDatabase _db;
  final ConnectivityService _connectivity;

  final _inFlight = <String>{};

  @override
  Future<void> toggleLike(Article article) async {
    if (!_inFlight.add(article.id)) return;
    try {
      final liked = !article.isLiked;
      final queued = await _db.outboxDao.put(
        MutationKind.reaction,
        article.id,
        liked,
      );
      if (!_connectivity.isOnline) return;

      final ReactionResponse response;
      try {
        response = await _api.setReaction(
          article.id,
          liked: liked,
          clientMutationId: queued.key,
          expectedVersion: article.version,
        );
      } on NetworkException {
        return;
      } on AppException {
        await _db.outboxDao.revert(queued);
        rethrow;
      }

      final (isLiked, likes, version) = switch (response) {
        ReactionSuccess(:final likes, :final version) => (
          liked,
          likes,
          version,
        ),
        ReactionConflict(:final isLiked, :final likes, :final version) => (
          isLiked,
          likes,
          version,
        ),
      };
      await _db.transaction(() async {
        await _db.articleDao.setServerReaction(
          article.id,
          isLiked: isLiked,
          likes: likes,
          version: version,
        );
        await _db.outboxDao.settle([queued.key]);
      });
    } finally {
      _inFlight.remove(article.id);
    }
  }
}
