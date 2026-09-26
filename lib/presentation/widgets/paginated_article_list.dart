import 'package:flutter/material.dart';

import '../../domain/entities/article.dart';
import '../pages/article_detail_page.dart';
import 'article_card.dart';
import 'feed_skeleton.dart';
import 'list_footer.dart';

enum ArticleListStatus { loading, failure, success }

class PaginatedArticleList extends StatefulWidget {
  const PaginatedArticleList({
    super.key,
    required this.status,
    required this.articles,
    required this.emptyBuilder,
    required this.errorBuilder,
    this.loadingView = const FeedSkeleton(),
    this.topicNames = const {},
    this.onLoadMore,
    this.onRefresh,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.loadMoreFailed = false,
  });

  final ArticleListStatus status;
  final List<Article> articles;
  final WidgetBuilder emptyBuilder;
  final WidgetBuilder errorBuilder;
  final Widget loadingView;

  final Map<String, String> topicNames;

  final VoidCallback? onLoadMore;

  final Future<void> Function()? onRefresh;

  final bool isLoadingMore;
  final bool hasMore;
  final bool loadMoreFailed;

  @override
  State<PaginatedArticleList> createState() => _PaginatedArticleListState();
}

class _PaginatedArticleListState extends State<PaginatedArticleList> {
  @override
  Widget build(BuildContext context) {
    switch (widget.status) {
      case ArticleListStatus.loading:
        return widget.loadingView;
      case ArticleListStatus.failure:
        return widget.errorBuilder(context);
      case ArticleListStatus.success:
        if (widget.articles.isEmpty) return widget.emptyBuilder(context);
        return _buildList(context);
    }
  }

  Widget _card(BuildContext context, Article article) {
    return ArticleCard(
      key: ValueKey(article.id),
      article: article,
      topicName: widget.topicNames[article.topicId],
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ArticleDetailPage(articleId: article.id),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final onLoadMore = widget.onLoadMore;

    Widget list = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: widget.articles.length + (onLoadMore != null ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == widget.articles.length) {
          return ListFooter(
            isLoading: widget.isLoadingMore,
            hasFailed: widget.loadMoreFailed,
            hasMore: widget.hasMore,
            onRetry: onLoadMore!,
          );
        }
        return _card(context, widget.articles[index]);
      },
    );

    if (onLoadMore != null) {
      list = NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!widget.isLoadingMore &&
              widget.hasMore &&
              !widget.loadMoreFailed) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 400) {
              onLoadMore();
            }
          }
          return false;
        },
        child: list,
      );
    }
    if (widget.onRefresh != null) {
      list = RefreshIndicator(onRefresh: widget.onRefresh!, child: list);
    }
    return list;
  }
}
