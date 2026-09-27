import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_cubit.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.showStale = false});

  final bool showStale;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        final String? message;
        final IconData icon;
        final bool isError;
        if (!state.isOnline) {
          message = state.pendingSyncCount > 0
              ? 'Offline — ${state.pendingSyncCount} '
                    '${state.pendingSyncCount == 1 ? 'change' : 'changes'} '
                    'will sync when you reconnect'
              : 'You are offline — showing saved content';
          icon = Icons.cloud_off_outlined;
          isError = true;
        } else if (state.isSyncing) {
          message =
              'Syncing ${state.syncingCount} '
              '${state.syncingCount == 1 ? 'change' : 'changes'}…';
          icon = Icons.sync;
          isError = false;
        } else if (state.syncedCount != null) {
          final count = state.syncedCount!;
          message = '$count ${count == 1 ? 'change' : 'changes'} synced';
          icon = Icons.check_circle_outline;
          isError = false;
        } else if (showStale) {
          message = 'Showing saved content — pull to refresh';
          icon = Icons.history;
          isError = false;
        } else {
          message = null;
          icon = Icons.history;
          isError = false;
        }

        final theme = Theme.of(context);
        final background = isError
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.secondaryContainer;
        final foreground = isError
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onSecondaryContainer;
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: message == null
              ? const SizedBox(width: double.infinity)
              : Semantics(
                  liveRegion: true,
                  child: Container(
                    width: double.infinity,
                    color: background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 16, color: foreground),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
