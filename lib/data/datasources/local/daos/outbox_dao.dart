import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

part 'outbox_dao.g.dart';

typedef QueuedMutation = ({String key, PendingMutation? replaced});

@DriftAccessor(tables: [PendingMutations])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.attachedDatabase);

  static const _uuid = Uuid();

  /// Queues [value] as the latest intent for this article, replacing any older
  /// one. The replaced row is returned so a failed attempt can be undone.
  Future<QueuedMutation> put(MutationKind kind, String articleId, bool value) {
    return transaction(() async {
      final replaced =
          await (select(pendingMutations)..where(
                (m) => m.kind.equalsValue(kind) & m.articleId.equals(articleId),
              ))
              .getSingleOrNull();
      final key = _uuid.v4();
      await into(pendingMutations).insertOnConflictUpdate(
        PendingMutationsCompanion.insert(
          kind: kind,
          articleId: articleId,
          value: value,
          idempotencyKey: key,
          queuedAt: DateTime.now(),
        ),
      );
      return (key: key, replaced: replaced);
    });
  }

  /// Keyed by idempotency key, so settling a stale attempt never removes a
  /// newer intent queued for the same article in the meantime.
  Future<void> settle(Iterable<String> keys) => (delete(
    pendingMutations,
  )..where((m) => m.idempotencyKey.isIn(keys))).go();

  Future<void> revert(QueuedMutation queued) {
    return transaction(() async {
      final removed = await (delete(
        pendingMutations,
      )..where((m) => m.idempotencyKey.equals(queued.key))).go();
      if (removed > 0 && queued.replaced != null) {
        await into(pendingMutations).insert(queued.replaced!);
      }
    });
  }

  Future<List<PendingMutation>> pending() => (select(
    pendingMutations,
  )..orderBy([(m) => OrderingTerm.asc(m.queuedAt)])).get();

  Stream<int> watchCount() {
    final count = pendingMutations.idempotencyKey.count();
    return (selectOnly(
      pendingMutations,
    )..addColumns([count])).map((row) => row.read(count)!).watchSingle();
  }
}
