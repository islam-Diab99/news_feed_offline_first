import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/network/connectivity_service.dart';
import 'package:vlau_assessment/data/datasources/local/app_database.dart';
import 'package:vlau_assessment/data/datasources/remote/api_client.dart';
import 'package:vlau_assessment/domain/entities/article.dart';
import 'package:vlau_assessment/domain/repositories/article_repository.dart';
import 'package:vlau_assessment/domain/repositories/feed_repository.dart';
import 'package:vlau_assessment/domain/repositories/search_repository.dart';
import 'package:vlau_assessment/domain/services/sync_service.dart';

class MockApi extends Mock implements ApiClient {}

class MockFeedRepository extends Mock implements FeedRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockArticleRepository extends Mock implements ArticleRepository {}

/// A real SQLite database in memory: tests exercise the same queries,
/// constraints and cascades as the app instead of a hand-written fake.
AppDatabase memoryDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

Article makeArticle(
  String id, {
  int likes = 10,
  bool isLiked = false,
  bool isBookmarked = false,
  int version = 1,
  DateTime? publishedAt,
}) {
  return Article(
    id: id,
    title: 'Title $id',
    summary: 'Summary $id',
    source: 'Source',
    authorName: 'Author',
    topicId: 't_technology',
    publishedAt: publishedAt ?? DateTime.utc(2026, 9, 14, 8, 30),
    likes: likes,
    comments: 3,
    isLiked: isLiked,
    isBookmarked: isBookmarked,
    version: version,
  );
}

class FakeConnectivity implements ConnectivityController {
  FakeConnectivity({bool online = true}) : _online = online;

  bool _online;
  final _controller = StreamController<bool>.broadcast();

  @override
  bool get isOnline => _online;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  bool get isSimulatedOffline => !_online;

  @override
  void setSimulatedOffline(bool offline) => setOnline(!offline);

  void setOnline(bool online) {
    _online = online;
    _controller.add(online);
  }

  @override
  Future<void> dispose() => _controller.close();
}

class FakeSyncService implements SyncService {
  @override
  Stream<int> get pendingCount => const Stream.empty();

  @override
  Stream<SyncActivity> get syncActivity => const Stream.empty();

  @override
  void start() {}

  @override
  Future<void> syncNow() async {}

  @override
  Future<void> dispose() async {}
}
