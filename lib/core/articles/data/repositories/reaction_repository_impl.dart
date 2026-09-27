import '../../../error/app_exception.dart';
import '../../../network/connectivity_service.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/reaction_repository.dart';
import '../local/app_database.dart';
import '../local/daos/articles_dao.dart';
import '../local/daos/outbox_dao.dart';
import '../local/db_transaction.dart';
import '../remote/api_client.dart';

class ReactionRepositoryImpl implements ReactionRepository {
  ReactionRepositoryImpl({
    required ApiClient api,
    required ArticlesDao articles,
    required OutboxDao outbox,
    required DbTransaction transaction,
    required ConnectivityService connectivity,
  }) : _api = api,
       _articles = articles,
       _outbox = outbox,
       _transaction = transaction,
       _connectivity = connectivity;

  final ApiClient _api;
  final ArticlesDao _articles;
  final OutboxDao _outbox;
  final DbTransaction _transaction;
  final ConnectivityService _connectivity;

  final _inFlight = <String>{};

  @override
  Future<void> toggleLike(Article article) async {
    if (!_inFlight.add(article.id)) return;
    try {
      final liked = !article.isLiked;
      final queued = await _outbox.put(
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
        await _outbox.revert(queued);
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
      await _transaction(() async {
        await _articles.setServerReaction(
          article.id,
          isLiked: isLiked,
          likes: likes,
          version: version,
        );
        await _outbox.settle([queued.key]);
      });
    } finally {
      _inFlight.remove(article.id);
    }
  }
}
