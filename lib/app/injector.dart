import 'package:drift_flutter/drift_flutter.dart';
import 'package:get_it/get_it.dart';

import '../core/articles/data/local/app_database.dart';
import '../core/articles/data/local/db_transaction.dart';
import '../core/articles/data/remote/api_client.dart';
import '../core/articles/data/remote/mock_api_client.dart';
import '../core/articles/data/repositories/bookmark_repository_impl.dart';
import '../core/articles/data/repositories/reaction_repository_impl.dart';
import '../core/articles/data/repositories/topic_repository_impl.dart';
import '../core/articles/domain/repositories/bookmark_repository.dart';
import '../core/articles/domain/repositories/reaction_repository.dart';
import '../core/articles/domain/repositories/topic_repository.dart';
import '../core/network/connectivity_service.dart';
import '../core/sync/outbox_sync_service.dart';
import '../core/sync/sync_service.dart';
import '../features/article_detail/data/article_repository_impl.dart';
import '../features/article_detail/domain/article_repository.dart';
import '../features/feed/data/feed_repository_impl.dart';
import '../features/feed/domain/feed_repository.dart';
import '../features/search/data/search_repository_impl.dart';
import '../features/search/domain/search_repository.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final connectivity = AppConnectivityService();
  sl.registerSingleton<ConnectivityController>(connectivity);
  sl.registerSingleton<ConnectivityService>(connectivity);
  final db = AppDatabase(driftDatabase(name: 'news_feed'));
  sl.registerSingleton<AppDatabase>(db, dispose: (db) => db.close());
  sl.registerSingleton(db.articlesDao);
  sl.registerSingleton(db.bookmarksDao);
  sl.registerSingleton(db.articleDetailsDao);
  sl.registerSingleton(db.feedDao);
  sl.registerSingleton(db.outboxDao);
  sl.registerSingleton(DbTransaction(db));
  sl.registerLazySingleton<ApiClient>(
    () => MockApiClient(connectivity: sl<ConnectivityService>()),
  );

  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(
      api: sl(),
      articles: sl(),
      feed: sl(),
      transaction: sl(),
    ),
  );
  sl.registerLazySingleton<TopicRepository>(
    () => TopicRepositoryImpl(api: sl()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(api: sl(), articles: sl()),
  );
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(
      api: sl(),
      articles: sl(),
      details: sl(),
      transaction: sl(),
    ),
  );
  sl.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepositoryImpl(
      api: sl(),
      bookmarks: sl(),
      outbox: sl(),
      transaction: sl(),
      connectivity: sl(),
    ),
  );
  sl.registerLazySingleton<ReactionRepository>(
    () => ReactionRepositoryImpl(
      api: sl(),
      articles: sl(),
      outbox: sl(),
      transaction: sl(),
      connectivity: sl(),
    ),
  );

  sl.registerSingleton<SyncService>(
    OutboxSyncService(
      api: sl(),
      articles: sl(),
      outbox: sl(),
      transaction: sl(),
      connectivity: sl(),
    )..start(),
  );
}
