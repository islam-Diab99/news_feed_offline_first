import 'package:drift_flutter/drift_flutter.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/remote/mock_api_client.dart';
import '../../data/repositories/article_repository_impl.dart';
import '../../data/repositories/bookmark_repository_impl.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../data/repositories/reaction_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../data/services/outbox_sync_service.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../domain/repositories/reaction_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/services/sync_service.dart';
import '../network/connectivity_service.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final connectivity = AppConnectivityService();
  sl.registerSingleton<ConnectivityController>(connectivity);
  sl.registerSingleton<ConnectivityService>(connectivity);
  sl.registerSingleton<AppDatabase>(
    AppDatabase(driftDatabase(name: 'news_feed')),
    dispose: (db) => db.close(),
  );
  sl.registerLazySingleton<ApiClient>(
    () => MockApiClient(connectivity: sl<ConnectivityService>()),
  );

  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(api: sl(), db: sl()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(api: sl(), db: sl()),
  );
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(api: sl(), db: sl()),
  );
  sl.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepositoryImpl(api: sl(), db: sl(), connectivity: sl()),
  );
  sl.registerLazySingleton<ReactionRepository>(
    () => ReactionRepositoryImpl(api: sl(), db: sl(), connectivity: sl()),
  );

  sl.registerSingleton<SyncService>(
    OutboxSyncService(api: sl(), db: sl(), connectivity: sl())..start(),
  );
}
