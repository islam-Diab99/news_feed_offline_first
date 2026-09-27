import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/topic.dart';
import '../blocs/feed/feed_bloc.dart';
import '../widgets/offline_banner.dart';
import '../widgets/paginated_article_list.dart';
import '../widgets/status_views.dart';
import 'home_shell.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        actions: const [OfflineToggleAction()],
      ),
      body: BlocListener<FeedBloc, FeedState>(
        listenWhen: (previous, current) =>
            current.notice != null && previous.noticeId != current.noticeId,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.notice!)));
        },
        child: Column(
          children: [
            BlocSelector<FeedBloc, FeedState, bool>(
              selector: (state) => state.isStale,
              builder: (context, isStale) => OfflineBanner(showStale: isStale),
            ),
            BlocBuilder<FeedBloc, FeedState>(
              buildWhen: (previous, current) =>
                  previous.topics != current.topics ||
                  previous.topicId != current.topicId,
              builder: (context, state) => state.topics.isEmpty
                  ? const SizedBox.shrink()
                  : _TopicChips(topics: state.topics, topicId: state.topicId),
            ),
            Expanded(
              child: BlocBuilder<FeedBloc, FeedState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.articles != current.articles ||
                    previous.topicNames != current.topicNames ||
                    previous.topicId != current.topicId ||
                    previous.hasMore != current.hasMore ||
                    previous.isLoadingMore != current.isLoadingMore ||
                    previous.loadMoreFailed != current.loadMoreFailed ||
                    previous.errorMessage != current.errorMessage,
                builder: (context, state) => _FeedBody(state: state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicChips extends StatelessWidget {
  const _TopicChips({required this.topics, required this.topicId});

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
              onSelected: (_) =>
                  context.read<FeedBloc>().add(const FeedTopicSelected(null)),
            );
          }
          final topic = topics[index - 1];
          return FilterChip(
            label: Text(topic.name),
            selected: topicId == topic.id,
            onSelected: (selected) => context.read<FeedBloc>().add(
              FeedTopicSelected(selected ? topic.id : null),
            ),
          );
        },
      ),
    );
  }
}

class _FeedBody extends StatelessWidget {
  const _FeedBody({required this.state});

  final FeedState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FeedBloc>();
    return PaginatedArticleList(
      status: switch (state.status) {
        FeedStatus.initial || FeedStatus.loading => ArticleListStatus.loading,
        FeedStatus.failure => ArticleListStatus.failure,
        FeedStatus.success => ArticleListStatus.success,
      },
      articles: state.articles,
      topicNames: state.topicNames,
      errorBuilder: (_) => ErrorView(
        message: state.errorMessage ?? 'Could not load the feed.',
        icon: Icons.cloud_off_outlined,
        onRetry: () => bloc.add(const FeedStarted()),
      ),
      emptyBuilder: (_) => EmptyView(
        title: 'No stories here yet',
        subtitle: state.topicId != null
            ? 'Try another topic, or pull to refresh.'
            : 'Pull to refresh.',
        icon: Icons.newspaper_outlined,
      ),
      onLoadMore: () => bloc.add(const FeedNextPageRequested()),
      onRefresh: bloc.refresh,
      isLoadingMore: state.isLoadingMore,
      hasMore: state.hasMore,
      loadMoreFailed: state.loadMoreFailed,
    );
  }
}
