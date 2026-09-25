import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vlau_assessment/data/datasources/remote/api_client.dart';
import 'package:vlau_assessment/data/datasources/remote/mock_api_client.dart';

import '../helpers.dart';

void main() {
  late MockApiClient api;

  setUp(() {
    api = MockApiClient(
      connectivity: FakeConnectivity(),
      loadAsset: (path) => File(path).readAsString(),
      latency: Duration.zero,
    );
  });

  test(
    'one refresh leaves a stale story whose next like always conflicts',
    () async {
      final page = await api.getFeed(page: 1);
      final stale = page.items.last;

      // A refresh bumps exactly one story server-side, deterministically.
      final updates = await api.getFeedUpdates(DateTime.now());
      expect(updates.updatedItems, [stale.id]);

      // The refreshed page 1 no longer contains it, so the client keeps the
      // version it already had.
      final head = await api.getFeed(page: 1);
      expect(head.items.map((a) => a.id), isNot(contains(stale.id)));

      final response = await api.setReaction(
        stale.id,
        liked: !stale.isLiked,
        clientMutationId: 'demo-1',
        expectedVersion: stale.version,
      );

      expect(response, isA<ReactionConflict>());
      final conflict = response as ReactionConflict;
      expect(conflict.likes, stale.likes + 3);
      expect(conflict.version, stale.version + 1);
    },
  );
  test('the first like on the top story conflicts, exactly once', () async {
    final page = await api.getFeed(page: 1);
    final top = page.items.first;

    final first = await api.setReaction(
      top.id,
      liked: true,
      clientMutationId: 'demo-1',
      expectedVersion: top.version,
    );

    expect(first, isA<ReactionConflict>());
    final conflict = first as ReactionConflict;
    expect(conflict.likes, top.likes + 3);
    expect(conflict.isLiked, isTrue);
    expect(conflict.version, top.version + 1);

    // Retrying with the version the conflict handed back now succeeds.
    final second = await api.setReaction(
      top.id,
      liked: false,
      clientMutationId: 'demo-2',
      expectedVersion: conflict.version,
    );
    expect(second, isA<ReactionSuccess>());
  });
}
