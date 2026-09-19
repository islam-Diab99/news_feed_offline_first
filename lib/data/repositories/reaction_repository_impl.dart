import 'package:uuid/uuid.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/article_update.dart';
import '../../domain/repositories/reaction_repository.dart';
import '../../domain/services/article_update_bus.dart';
import '../datasources/local/local_store.dart';
import '../datasources/remote/api_client.dart';
import '../models/outbox_mutation.dart';

class ReactionRepositoryImpl implements ReactionRepository {
  ReactionRepositoryImpl({
    required ApiClient api,
    required LocalStore store,
    required ConnectivityService connectivity,
    required ArticleUpdateBus bus,
    Uuid uuid = const Uuid(),
  }) : _api = api,
       _store = store,
       _connectivity = connectivity,
       _bus = bus,
       _uuid = uuid;

  final ApiClient _api;
  final LocalStore _store;
  final ConnectivityService _connectivity;
  final ArticleUpdateBus _bus;
  final Uuid _uuid;

  final _inFlight = <String>{};

  @override
  Future<void> toggleLike(Article article) async {
    if (_inFlight.contains(article.id)) return;
    _inFlight.add(article.id);

    final liked = !article.isLiked;
    final optimistic = article.copyWith(
      isLiked: liked,
      likes: article.likes + (liked ? 1 : -1),
    );
    await _commit(optimistic);

    try {
      if (!_connectivity.isOnline) {
        await _enqueue(article.id, liked);
        return;
      }

      final response = await _api.setReaction(
        article.id,
        liked: liked,
        clientMutationId: _uuid.v4(),
        expectedVersion: article.version,
      );

      switch (response) {
        case ReactionSuccess(:final likes, :final version):
          await _commit(optimistic.copyWith(likes: likes, version: version));
        case ReactionConflict(:final isLiked, :final likes, :final version):
          await _commit(
            article.copyWith(isLiked: isLiked, likes: likes, version: version),
          );
      }
    } on NetworkException {
      await _enqueue(article.id, liked);
    } on AppException {
      await _commit(article);
      rethrow;
    } finally {
      _inFlight.remove(article.id);
    }
  }

  Future<void> _commit(Article article) async {
    await _store.upsertArticles([article]);
    _bus.publish(ArticleChanged(article));
  }

  Future<void> _enqueue(String articleId, bool liked) async {
    final stale = (await _store.pendingMutations())
        .where(
          (m) =>
              m.op == OutboxMutation.opSetReaction && m.articleId == articleId,
        )
        .map((m) => m.idempotencyKey);
    await _store.removeMutations(stale);

    await _store.enqueueMutation(
      OutboxMutation(
        idempotencyKey: _uuid.v4(),
        op: OutboxMutation.opSetReaction,
        articleId: articleId,
        payload: {
          'articleId': articleId,
          'reaction': liked ? 'like' : 'unlike',
        },
        queuedAt: DateTime.now(),
      ),
    );
  }
}
