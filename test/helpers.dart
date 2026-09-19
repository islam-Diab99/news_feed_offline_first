import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/network/connectivity_service.dart';
import 'package:vlau_assessment/data/datasources/local/local_store.dart';
import 'package:vlau_assessment/data/datasources/remote/api_client.dart';
import 'package:vlau_assessment/data/models/outbox_mutation.dart';
import 'package:vlau_assessment/domain/entities/article.dart';
import 'package:vlau_assessment/domain/entities/article_detail.dart';
import 'package:vlau_assessment/domain/repositories/feed_repository.dart';
import 'package:vlau_assessment/domain/repositories/search_repository.dart';
import 'package:vlau_assessment/domain/services/sync_service.dart';

class MockApi extends Mock implements ApiClient {}

class MockFeedRepository extends Mock implements FeedRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

Article makeArticle(
  String id, {
  int likes = 10,
  bool isLiked = false,
  bool isBookmarked = false,
  int version = 1,
}) {
  return Article(
    id: id,
    title: 'Title $id',
    summary: 'Summary $id',
    source: 'Source',
    authorName: 'Author',
    topicId: 't_technology',
    publishedAt: DateTime.utc(2026, 9, 14, 8, 30),
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

class InMemoryLocalStore implements LocalStore {
  final articles = <String, Article>{};
  final feeds = <String, CachedFeed>{};
  final details = <String, CachedDetail>{};
  final bookmarks = <String, Article>{};
  final outbox = <String, OutboxMutation>{};
  DateTime? lastSync;

  @override
  Future<void> saveFeedSnapshot(
    String filterKey,
    List<Article> items, {
    String? nextCursor,
  }) async {
    await upsertArticles(items);
    feeds[filterKey] = CachedFeed(
      articles: items,
      savedAt: DateTime.now(),
      nextCursor: nextCursor,
    );
  }

  @override
  Future<CachedFeed?> feedSnapshot(String filterKey) async {
    final feed = feeds[filterKey];
    if (feed == null) return null;
    return CachedFeed(
      articles: feed.articles.map((a) => articles[a.id] ?? a).toList(),
      savedAt: feed.savedAt,
      nextCursor: feed.nextCursor,
    );
  }

  @override
  Future<void> upsertArticles(List<Article> items) async {
    for (final article in items) {
      articles[article.id] = article;
    }
  }

  @override
  Future<Article?> article(String id) async => articles[id];

  @override
  Future<void> removeArticle(String id) async {
    articles.remove(id);
    details.remove(id);
  }

  @override
  Future<List<Article>> allArticles() async => articles.values.toList();

  @override
  Future<void> saveDetail(ArticleDetail detail) async {
    details[detail.article.id] = CachedDetail(
      detail: detail,
      savedAt: DateTime.now(),
    );
    await upsertArticles([detail.article]);
  }

  @override
  Future<CachedDetail?> detail(String id) async => details[id];

  @override
  Future<void> saveBookmark(Article article) async {
    bookmarks[article.id] = article.copyWith(isBookmarked: true);
  }

  @override
  Future<void> removeBookmark(String id) async => bookmarks.remove(id);

  @override
  Future<List<Article>> bookmarkedArticles() async =>
      bookmarks.values.map((a) => articles[a.id] ?? a).toList();

  @override
  Future<bool> isBookmarked(String id) async => bookmarks.containsKey(id);

  final _outboxChanges = StreamController<void>.broadcast();

  @override
  Future<void> enqueueMutation(OutboxMutation mutation) async {
    outbox[mutation.idempotencyKey] = mutation;
    _outboxChanges.add(null);
  }

  @override
  Future<List<OutboxMutation>> pendingMutations() async =>
      outbox.values.toList()..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));

  @override
  Future<void> removeMutations(Iterable<String> idempotencyKeys) async {
    for (final key in idempotencyKeys) {
      outbox.remove(key);
    }
    _outboxChanges.add(null);
  }

  @override
  Stream<void> get outboxChanges => _outboxChanges.stream;

  @override
  Future<DateTime?> lastFeedSyncTime() async => lastSync;

  @override
  Future<void> setLastFeedSyncTime(DateTime time) async => lastSync = time;
}
