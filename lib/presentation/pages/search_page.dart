import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/topic.dart';
import '../blocs/search/search_bloc.dart';
import '../widgets/feed_skeleton.dart';
import '../widgets/offline_banner.dart';
import '../widgets/paginated_article_list.dart';
import '../widgets/status_views.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          BlocSelector<SearchBloc, SearchState, bool>(
            selector: (state) => state.isStale,
            builder: (context, isStale) => OfflineBanner(showStale: isStale),
          ),
          const _SearchField(),
          BlocBuilder<SearchBloc, SearchState>(
            buildWhen: (previous, current) =>
                previous.topics != current.topics ||
                previous.sources != current.sources ||
                previous.topicId != current.topicId ||
                previous.source != current.source,
            builder: (context, state) => _Filters(state: state),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.results != current.results ||
                  previous.query != current.query ||
                  previous.nextCursor != current.nextCursor ||
                  previous.isLoadingMore != current.isLoadingMore ||
                  previous.loadMoreFailed != current.loadMoreFailed ||
                  previous.errorMessage != current.errorMessage,
              builder: (context, state) => _SearchBody(state: state),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        onChanged: (query) =>
            context.read<SearchBloc>().add(SearchQueryChanged(query)),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search headlines and summaries…',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          isDense: true,
        ),
      ),
    );
  }
}

/// Topics and sources are two different axes, so they get two rows instead of
/// one long scroller: a single row buried every source chip off-screen to the
/// right of the topic chips, where nobody found them.
class _Filters extends StatelessWidget {
  const _Filters({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    if (state.topics.isEmpty && state.sources.isEmpty) {
      return const SizedBox(height: 8);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.topics.isNotEmpty)
          _TopicRow(topics: state.topics, topicId: state.topicId),
        if (state.sources.isNotEmpty)
          _SourceRow(
            sources: state.sources,
            source: state.source,
            hasTopic: state.topicId != null,
          ),
      ],
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topics, required this.topicId});

  final List<Topic> topics;
  final String? topicId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: topics.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('All'),
              selected: topicId == null,
              onSelected: (_) => context.read<SearchBloc>().add(
                const SearchTopicFilterChanged(null),
              ),
            );
          }
          final topic = topics[index - 1];
          return FilterChip(
            label: Text(topic.name),
            selected: topicId == topic.id,
            onSelected: (selected) => context.read<SearchBloc>().add(
              SearchTopicFilterChanged(selected ? topic.id : null),
            ),
          );
        },
      ),
    );
  }
}

/// A menu rather than a chip strip: the unfiltered list is 15 sources wide,
/// and only narrows to two or three once a topic is picked.
class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.sources,
    required this.source,
    required this.hasTopic,
  });

  final List<String> sources;
  final String? source;
  final bool hasTopic;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SearchBloc>();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Flexible(
            child: MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  leadingIcon: Icon(
                    Icons.check,
                    size: 18,
                    color: source == null ? null : Colors.transparent,
                  ),
                  onPressed: () =>
                      bloc.add(const SearchSourceFilterChanged(null)),
                  child: const Text('All sources'),
                ),
                for (final option in sources)
                  MenuItemButton(
                    leadingIcon: Icon(
                      Icons.check,
                      size: 18,
                      color: source == option ? null : Colors.transparent,
                    ),
                    onPressed: () =>
                        bloc.add(SearchSourceFilterChanged(option)),
                    child: Text(option),
                  ),
              ],
              builder: (context, controller, _) {
                final selected = source != null;
                return OutlinedButton.icon(
                  onPressed: () =>
                      controller.isOpen ? controller.close() : controller.open(),
                  icon: const Icon(Icons.rss_feed, size: 18),
                  label: Text(
                    source ?? 'All sources',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: selected
                        ? theme.colorScheme.onSecondaryContainer
                        : null,
                    backgroundColor: selected
                        ? theme.colorScheme.secondaryContainer
                        : null,
                    side: selected
                        ? BorderSide(color: theme.colorScheme.secondary)
                        : null,
                  ),
                );
              },
            ),
          ),
          if (hasTopic || source != null)
            TextButton(
              onPressed: () => bloc.add(const SearchFiltersCleared()),
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SearchBloc>();
    if (state.status == SearchStatus.idle) {
      return const EmptyView(
        title: 'Search the news',
        subtitle: 'Find stories by headline, summary, or tag.',
        icon: Icons.manage_search,
      );
    }
    return PaginatedArticleList(
      status: switch (state.status) {
        SearchStatus.loading => ArticleListStatus.loading,
        SearchStatus.failure => ArticleListStatus.failure,
        SearchStatus.idle || SearchStatus.success => ArticleListStatus.success,
      },
      articles: state.results,
      loadingView: const FeedSkeleton(itemCount: 3),
      errorBuilder: (_) => ErrorView(
        message: state.errorMessage ?? 'Search failed.',
        onRetry: () => bloc.add(const SearchRetryRequested()),
      ),
      emptyBuilder: (_) => EmptyView(
        title: 'No results for "${state.query}"',
        subtitle: 'Try different keywords or clear the filters.',
        icon: Icons.search_off,
      ),
      onLoadMore: () => bloc.add(const SearchNextPageRequested()),
      isLoadingMore: state.isLoadingMore,
      hasMore: state.nextCursor != null,
      loadMoreFailed: state.loadMoreFailed,
    );
  }
}
