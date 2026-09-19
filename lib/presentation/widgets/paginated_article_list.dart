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

  /// Builders so the empty/error views are only constructed when shown.
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
  /// Returning the identical [ArticleCard] instance for an unchanged article
  /// lets the framework skip rebuilding that row when the list re-renders
  /// (e.g. a like on one article replaces the whole articles list).
  final _cardCache = <String, ArticleCard>{};

  @override
  void didUpdateWidget(PaginatedArticleList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.articles, widget.articles)) {
      final ids = {for (final a in widget.articles) a.id};
      _cardCache.removeWhere((id, _) => !ids.contains(id));
    }
  }

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
    final topicName = widget.topicNames[article.topicId];
    final cached = _cardCache[article.id];
    if (cached != null &&
        cached.article == article &&
        cached.topicName == topicName) {
      return cached;
    }
    final card = ArticleCard(
      key: ValueKey(article.id),
      article: article,
      topicName: topicName,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ArticleDetailPage(articleId: article.id),
        ),
      ),
    );
    _cardCache[article.id] = card;
    return card;
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
