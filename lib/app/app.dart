import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/articles/presentation/engagement/engagement_bloc.dart';
import '../core/sync/presentation/connectivity_cubit.dart';
import '../core/theme/app_theme.dart';
import '../features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import '../features/feed/presentation/bloc/feed_bloc.dart';
import '../features/search/presentation/bloc/search_bloc.dart';
import 'home_shell.dart';
import 'injector.dart';

class NewsFeedApp extends StatelessWidget {
  const NewsFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ConnectivityCubit(connectivity: sl(), syncService: sl()),
        ),
        BlocProvider(
          create: (_) => EngagementBloc(
            reactionRepository: sl(),
            bookmarkRepository: sl(),
          ),
        ),
        BlocProvider(
          create: (_) =>
              FeedBloc(feedRepository: sl(), topicRepository: sl())
                ..add(const FeedStarted()),
        ),
        BlocProvider(
          create: (_) =>
              SearchBloc(searchRepository: sl(), topicRepository: sl())
                ..add(const SearchStarted()),
        ),
        BlocProvider(
          create: (_) =>
              BookmarksBloc(bookmarkRepository: sl())
                ..add(const BookmarksRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'News Feed',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const HomeShell(),
      ),
    );
  }
}
