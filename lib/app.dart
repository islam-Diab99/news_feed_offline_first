import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/bookmarks/bookmarks_bloc.dart';
import 'presentation/blocs/connectivity/connectivity_cubit.dart';
import 'presentation/blocs/engagement/engagement_bloc.dart';
import 'presentation/blocs/feed/feed_bloc.dart';
import 'presentation/blocs/search/search_bloc.dart';
import 'presentation/pages/home_shell.dart';

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
              FeedBloc(feedRepository: sl(), searchRepository: sl(), bus: sl())
                ..add(const FeedStarted()),
        ),
        BlocProvider(
          create: (_) =>
              SearchBloc(searchRepository: sl(), bus: sl())
                ..add(const SearchStarted()),
        ),
        BlocProvider(
          create: (_) =>
              BookmarksBloc(bookmarkRepository: sl(), bus: sl())
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
