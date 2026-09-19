import 'package:flutter/material.dart';

class ListFooter extends StatelessWidget {
  const ListFooter({
    super.key,
    required this.isLoading,
    required this.hasFailed,
    required this.hasMore,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasFailed;
  final bool hasMore;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: switch ((isLoading, hasFailed, hasMore)) {
          (true, _, _) => const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              semanticsLabel: 'Loading more stories',
            ),
          ),
          (_, true, _) => Column(
            children: [
              Text(
                'Could not load more stories.',
                style: theme.textTheme.bodyMedium,
              ),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
          (_, _, false) => Text(
            'You are all caught up',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
