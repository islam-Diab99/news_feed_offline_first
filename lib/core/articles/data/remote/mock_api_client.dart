import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../../../error/app_exception.dart';
import '../../../network/connectivity_service.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/topic.dart';
import '../models/article_detail_model.dart';
import '../models/article_model.dart';
import '../models/outbox_mutation.dart';
import '../models/topic_model.dart';
import 'api_client.dart';

class MockApiClient implements ApiClient {
  MockApiClient({
    required ConnectivityService connectivity,
    Future<String> Function(String assetPath)? loadAsset,
    Duration? latency,
    Random? random,
  }) : _connectivity = connectivity,
       _loadAsset = loadAsset ?? rootBundle.loadString,
       _fixedLatency = latency,
       _random = random ?? Random();

  static const _pageSize = 10;

  final ConnectivityService _connectivity;
  final Future<String> Function(String assetPath) _loadAsset;
  final Duration? _fixedLatency;
  final Random _random;

  List<Topic> _topics = [];
  Map<String, List<String>> _sources = {};

  final Map<String, Map<String, dynamic>> _records = {};

  final List<String> _publishedIds = [];
  final List<String> _reserveIds = [];
  final Set<String> _deletedIds = {};

  int _reactionCalls = 0;
  int _refreshCalls = 0;
  bool _conflictArmed = true;

  Future<void>? _loading;

  Future<void> _ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    final topicsJson =
        jsonDecode(await _loadAsset('assets/mock/topics.json')) as List;
    _topics = topicsJson
        .cast<Map<String, dynamic>>()
        .map(TopicModel.fromJson)
        .toList();

    final sourcesJson =
        jsonDecode(await _loadAsset('assets/mock/sources.json'))
            as Map<String, dynamic>;
    _sources = sourcesJson.map(
      (topic, list) => MapEntry(topic, (list as List).cast<String>()),
    );

    final articlesJson =
        jsonDecode(await _loadAsset('assets/mock/articles.json')) as List;
    for (final raw in articlesJson.cast<Map<String, dynamic>>()) {
      final record = Map<String, dynamic>.from(raw);
      final id = record['id'] as String;
      _records[id] = record;
      if (record.remove('reserved') == true) {
        _reserveIds.add(id);
      } else {
        _publishedIds.add(id);
      }
    }
  }

  Future<void> _network([double extra = 0]) async {
    if (!_connectivity.isOnline) {
      throw const NetworkException();
    }
    final latency =
        _fixedLatency ??
        Duration(
          milliseconds: 300 + _random.nextInt(400) + (extra * 300).round(),
        );
    await Future<void>.delayed(latency);
    if (!_connectivity.isOnline) {
      throw const NetworkException('Connection lost during request.');
    }
  }

  List<Map<String, dynamic>> _liveRecords({String? topicId, String? source}) {
    final records = _publishedIds
        .where((id) => !_deletedIds.contains(id))
        .map((id) => _records[id]!)
        .where((r) => topicId == null || r['topicId'] == topicId)
        .where((r) => source == null || r['source'] == source)
        .toList();
    records.sort(
      (a, b) =>
          (b['publishedAt'] as String).compareTo(a['publishedAt'] as String),
    );
    return records;
  }

  @override
  Future<List<Topic>> getTopics() async {
    await _ensureLoaded();
    await _network();
    return _topics;
  }

  @override
  Future<List<String>> getSources({String? topicId}) async {
    await _ensureLoaded();
    await _network();
    if (topicId != null) return _sources[topicId] ?? const [];
    return _sources.values.expand((s) => s).toSet().toList()..sort();
  }

  @override
  Future<FeedPageResponse> getFeed({
    int page = 1,
    String? cursor,
    int pageSize = _pageSize,
    String? topicId,
    String? source,
  }) async {
    await _ensureLoaded();
    await _network();

    final effectivePage = switch (cursor) {
      final c? when c.startsWith('feed_') =>
        int.tryParse(c.substring(5)) ?? page,
      _ => page,
    };

    final all = _liveRecords(topicId: topicId, source: source);
    final start = (effectivePage - 1) * pageSize;
    final slice = start >= all.length
        ? const <Map<String, dynamic>>[]
        : all.sublist(start, min(start + pageSize, all.length));
    final hasMore = start + pageSize < all.length;

    return FeedPageResponse(
      items: slice.map(ArticleModel.fromJson).toList(),
      page: effectivePage,
      total: all.length,
      nextCursor: hasMore ? 'feed_${effectivePage + 1}' : null,
    );
  }

  @override
  Future<FeedUpdatesResponse> getFeedUpdates(DateTime since) async {
    await _ensureLoaded();
    await _network();
    _refreshCalls++;

    final newItems = <String>[];
    final updatedItems = <String>[];
    final deletedItems = <String>[];

    if (_reserveIds.isNotEmpty) {
      final id = _reserveIds.removeAt(0);
      _records[id]!['publishedAt'] = DateTime.now().toUtc().toIso8601String();
      _publishedIds.add(id);
      newItems.add(id);
    }

    // Simulate another reader by bumping one story per refresh. The target is
    // deterministic on purpose: the first story on page 2, which a refresh does
    // not re-fetch, so a client that paginated past page 1 is left holding a
    // stale version and the next like reliably hits the conflict branch of
    // [setReaction]. Random targets made that path impossible to demo.
    final live = _liveRecords();
    if (live.isNotEmpty) {
      final record =
          live[live.length > _pageSize ? _pageSize : live.length - 1];
      record['likes'] = (record['likes'] as int) + 3;
      record['version'] = (record['version'] as int? ?? 1) + 1;
      updatedItems.add(record['id'] as String);
    }

    if (_refreshCalls == 2) {
      final target = _publishedIds.lastWhere(
        (id) => !_deletedIds.contains(id) && !newItems.contains(id),
        orElse: () => '',
      );
      if (target.isNotEmpty) {
        _deletedIds.add(target);
        deletedItems.add(target);
      }
    }

    return FeedUpdatesResponse(
      newItems: newItems,
      updatedItems: updatedItems,
      deletedItems: deletedItems,
      serverTime: DateTime.now().toUtc(),
    );
  }

  @override
  Future<ArticleDetailResponse> getArticle(String id) async {
    await _ensureLoaded();
    await _network(0.3);

    if (_deletedIds.contains(id)) {
      return ArticleUnavailable(id, reason: 'removed_by_publisher');
    }
    final record = _records[id];
    if (record == null || _reserveIds.contains(id)) {
      throw const NotFoundException('This article does not exist.');
    }
    return ArticleDetailData(ArticleDetailModel.fromJson(record));
  }

  @override
  Future<FeedPageResponse> search(
    String query, {
    int page = 1,
    int pageSize = _pageSize,
    String? topicId,
    String? source,
  }) async {
    await _ensureLoaded();
    await _network(0.5);

    final needle = query.trim().toLowerCase();
    final hits = _liveRecords(topicId: topicId, source: source)
        .where(
          (r) =>
              (r['title'] as String).toLowerCase().contains(needle) ||
              (r['summary'] as String).toLowerCase().contains(needle) ||
              (r['tags'] as List? ?? const []).any(
                (t) => (t as String).toLowerCase().contains(needle),
              ),
        )
        .toList();

    final start = (page - 1) * pageSize;
    final slice = start >= hits.length
        ? const <Map<String, dynamic>>[]
        : hits.sublist(start, min(start + pageSize, hits.length));

    return FeedPageResponse(
      items: slice.map(ArticleModel.fromJson).toList(),
      page: page,
      total: hits.length,
      nextCursor: start + pageSize < hits.length ? 'search_${page + 1}' : null,
    );
  }

  @override
  Future<ReactionResponse> setReaction(
    String articleId, {
    required bool liked,
    required String clientMutationId,
    required int expectedVersion,
  }) async {
    await _ensureLoaded();
    await _network();

    final record = _records[articleId];
    if (record == null || _deletedIds.contains(articleId)) {
      throw const NotFoundException('This article is no longer available.');
    }

    _reactionCalls++;
    if (_reactionCalls % 3 == 0) {
      throw const ServerException('Reaction was not saved. Please retry.');
    }

    // Demo hook, fires once: the first like on the story at the top of the
    // feed simulates another reader getting there a moment earlier, so the
    // version-conflict path is reachable with a single tap — no pagination or
    // refreshes needed.
    if (_conflictArmed && articleId == _liveRecords().first['id']) {
      _conflictArmed = false;
      record['isLiked'] = true;
      record['likes'] = (record['likes'] as int) + 3;
      record['version'] = (record['version'] as int? ?? 1) + 1;
    }

    final serverVersion = record['version'] as int? ?? 1;
    if (expectedVersion < serverVersion) {
      return ReactionConflict(
        isLiked: record['isLiked'] as bool? ?? false,
        likes: record['likes'] as int,
        version: serverVersion,
      );
    }

    final wasLiked = record['isLiked'] as bool? ?? false;
    final likes = record['likes'] as int;
    record['isLiked'] = liked;
    record['likes'] = liked == wasLiked ? likes : likes + (liked ? 1 : -1);
    record['version'] = serverVersion + 1;

    return ReactionSuccess(
      likes: record['likes'] as int,
      version: record['version'] as int,
    );
  }

  @override
  Future<void> setBookmark(String articleId, {required bool bookmarked}) async {
    await _ensureLoaded();
    await _network();
    _records[articleId]?['isBookmarked'] = bookmarked;
  }

  @override
  Future<SyncResponse> sync(List<OutboxMutation> mutations) async {
    await _ensureLoaded();
    await _network(0.5);

    final applied = <String>[];
    final conflicts = <Article>[];

    for (final mutation in mutations) {
      final record = _records[mutation.articleId];
      if (record == null || _deletedIds.contains(mutation.articleId)) {
        applied.add(mutation.idempotencyKey);
        continue;
      }
      switch (mutation.op) {
        case OutboxMutation.opSetReaction:
          final liked = mutation.payload['reaction'] == 'like';
          final wasLiked = record['isLiked'] as bool? ?? false;
          if (wasLiked == liked) {
            conflicts.add(ArticleModel.fromJson(record));
          } else {
            record['isLiked'] = liked;
            record['likes'] = (record['likes'] as int) + (liked ? 1 : -1);
            record['version'] = (record['version'] as int? ?? 1) + 1;
          }
          applied.add(mutation.idempotencyKey);
        case OutboxMutation.opSetBookmark:
          record['isBookmarked'] = mutation.payload['bookmarked'] == true;
          applied.add(mutation.idempotencyKey);
        default:
          applied.add(mutation.idempotencyKey);
      }
    }

    return SyncResponse(applied: applied, conflicts: conflicts);
  }
}
