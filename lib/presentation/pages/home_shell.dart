import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/connectivity/connectivity_cubit.dart';
import '../blocs/engagement/engagement_bloc.dart';
import 'bookmarks_page.dart';
import 'feed_page.dart';
import 'search_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EngagementBloc, EngagementState>(
      listenWhen: (previous, current) =>
          current.notice != null && previous.noticeId != current.noticeId,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.notice!)));
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [FeedPage(), SearchPage(), BookmarksPage()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              selectedIcon: Icon(Icons.newspaper),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmarks_outlined),
              selectedIcon: Icon(Icons.bookmarks),
              label: 'Bookmarks',
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineToggleAction extends StatelessWidget {
  const OfflineToggleAction({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return IconButton(
          tooltip: state.isSimulatedOffline
              ? 'Go back online (demo)'
              : 'Simulate offline (demo)',
          isSelected: state.isSimulatedOffline,
          onPressed: () =>
              context.read<ConnectivityCubit>().toggleSimulatedOffline(),
          icon: const Icon(Icons.wifi),
          selectedIcon: Icon(
            Icons.wifi_off,
            color: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }
}
