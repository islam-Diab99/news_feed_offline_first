import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class _Filters extends StatelessWidget {
  const _Filters({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    if (state.topics.isEmpty && state.sources.isEmpty) {
      return const SizedBox(height: 8);
    }
    final bloc = context.read<SearchBloc>();
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          for (final topic in state.topics) ...[
            FilterChip(
              label: Text(topic.name),
              selected: state.topicId == topic.id,
              onSelected: (selected) => bloc.add(
                SearchTopicFilterChanged(selected ? topic.id : null),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (state.sources.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: VerticalDivider(width: 8),
            ),
          for (final source in state.sources) ...[
            FilterChip(
              avatar: const Icon(Icons.rss_feed, size: 16),
              label: Text(source),
              selected: state.source == source,
              onSelected: (selected) =>
                  bloc.add(SearchSourceFilterChanged(selected ? source : null)),
            ),
            const SizedBox(width: 8),
          ],
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
