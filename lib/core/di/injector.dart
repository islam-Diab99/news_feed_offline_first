import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../data/datasources/local/hive_local_store.dart';
import '../../data/datasources/local/local_store.dart';
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
import '../../domain/services/article_update_bus.dart';
import '../../domain/services/sync_service.dart';
import '../network/connectivity_service.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  await Hive.initFlutter();

  final connectivity = AppConnectivityService();
  sl.registerSingleton<ConnectivityController>(connectivity);
  sl.registerSingleton<ConnectivityService>(connectivity);
  sl.registerSingleton<ArticleUpdateBus>(ArticleUpdateBus());

  sl.registerSingleton<LocalStore>(await HiveLocalStore.open());
  sl.registerLazySingleton<ApiClient>(
    () => MockApiClient(connectivity: sl<ConnectivityService>()),
  );

  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(api: sl(), store: sl()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(api: sl(), store: sl()),
  );
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(api: sl(), store: sl(), bus: sl()),
  );
  sl.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepositoryImpl(
      api: sl(),
      store: sl(),
      connectivity: sl(),
      bus: sl(),
    ),
  );
  sl.registerLazySingleton<ReactionRepository>(
    () => ReactionRepositoryImpl(
      api: sl(),
      store: sl(),
      connectivity: sl(),
      bus: sl(),
    ),
  );

  sl.registerSingleton<SyncService>(
    OutboxSyncService(api: sl(), store: sl(), connectivity: sl(), bus: sl())
      ..start(),
  );
}
