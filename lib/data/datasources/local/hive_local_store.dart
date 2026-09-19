import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_detail.dart';
import '../../models/article_detail_model.dart';
import '../../models/article_model.dart';
import '../../models/outbox_mutation.dart';
import 'local_store.dart';

class HiveLocalStore implements LocalStore {
  HiveLocalStore._(
    this._articles,
    this._feeds,
    this._details,
    this._bookmarks,
    this._outbox,
    this._meta,
  );

  static Future<HiveLocalStore> open() async {
    return HiveLocalStore._(
      await Hive.openBox<String>('articles'),
      await Hive.openBox<String>('feed_snapshots'),
      await Hive.openBox<String>('details'),
      await Hive.openBox<String>('bookmarks'),
      await Hive.openBox<String>('outbox'),
      await Hive.openBox<String>('meta'),
    );
  }

  final Box<String> _articles;
  final Box<String> _feeds;
  final Box<String> _details;
  final Box<String> _bookmarks;
  final Box<String> _outbox;
  final Box<String> _meta;

  @override
  Future<void> saveFeedSnapshot(
    String filterKey,
    List<Article> articles, {
    String? nextCursor,
  }) async {
    await upsertArticles(articles);
    await _feeds.put(
      filterKey,
      jsonEncode({
        'ids': articles.map((a) => a.id).toList(),
        'nextCursor': nextCursor,
        'savedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  @override
  Future<CachedFeed?> feedSnapshot(String filterKey) async {
    final raw = _feeds.get(filterKey);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final articles = <Article>[];

    for (final id in (json['ids'] as List).cast<String>().toSet()) {
      final article = await this.article(id);
      if (article != null) articles.add(article);
    }
    return CachedFeed(
      articles: articles,
      nextCursor: json['nextCursor'] as String?,
      savedAt:
          DateTime.tryParse(json['savedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<void> upsertArticles(List<Article> articles) async {
    await _articles.putAll({
      for (final article in articles)
        article.id: jsonEncode(ArticleModel.toJson(article)),
    });
  }

  @override
  Future<Article?> article(String id) async {
    final raw = _articles.get(id);
    if (raw == null) return null;
    return ArticleModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> removeArticle(String id) async {
    await _articles.delete(id);
    await _details.delete(id);
  }

  @override
  Future<List<Article>> allArticles() async {
    return _articles.values
        .map(
          (raw) =>
              ArticleModel.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveDetail(ArticleDetail detail) async {
    await _details.put(
      detail.article.id,
      jsonEncode({
        'detail': ArticleDetailModel.toJson(detail),
        'savedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    await upsertArticles([detail.article]);
  }

  @override
  Future<CachedDetail?> detail(String id) async {
    final raw = _details.get(id);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    var detail = ArticleDetailModel.fromJson(
      (json['detail'] as Map).cast<String, dynamic>(),
    );

    final cachedArticle = await article(id);
    if (cachedArticle != null) detail = detail.withArticle(cachedArticle);
    return CachedDetail(
      detail: detail,
      savedAt:
          DateTime.tryParse(json['savedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<void> saveBookmark(Article article) async {
    await _bookmarks.put(
      article.id,
      jsonEncode({
        'article': ArticleModel.toJson(article.copyWith(isBookmarked: true)),
        'savedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  @override
  Future<void> removeBookmark(String id) => _bookmarks.delete(id);

  @override
  Future<List<Article>> bookmarkedArticles() async {
    final entries =
        _bookmarks.values
            .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
            .toList()
          ..sort(
            (a, b) =>
                (b['savedAt'] as String).compareTo(a['savedAt'] as String),
          );
    final articles = <Article>[];
    for (final entry in entries) {
      final stored = ArticleModel.fromJson(
        (entry['article'] as Map).cast<String, dynamic>(),
      );

      final cached = await article(stored.id);
      articles.add((cached ?? stored).copyWith(isBookmarked: true));
    }
    return articles;
  }

  @override
  Future<bool> isBookmarked(String id) async => _bookmarks.containsKey(id);

  @override
  Future<void> enqueueMutation(OutboxMutation mutation) async {
    await _outbox.put(mutation.idempotencyKey, jsonEncode(mutation.toJson()));
  }

  @override
  Future<List<OutboxMutation>> pendingMutations() async {
    return _outbox.values
        .map(
          (raw) =>
              OutboxMutation.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList()
      ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
  }

  @override
  Future<void> removeMutations(Iterable<String> idempotencyKeys) =>
      _outbox.deleteAll(idempotencyKeys);

  @override
  Stream<void> get outboxChanges => _outbox.watch();

  @override
  Future<DateTime?> lastFeedSyncTime() async {
    final raw = _meta.get('lastFeedSync');
    return raw == null ? null : DateTime.tryParse(raw);
  }

  @override
  Future<void> setLastFeedSyncTime(DateTime time) =>
      _meta.put('lastFeedSync', time.toUtc().toIso8601String());
}
