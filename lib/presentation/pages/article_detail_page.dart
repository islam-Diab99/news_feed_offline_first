import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/utils/relative_time.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/article_detail.dart';
import '../blocs/article_detail/article_detail_bloc.dart';
import '../blocs/engagement/engagement_bloc.dart';
import '../widgets/app_network_image.dart';
import '../widgets/offline_banner.dart';
import '../widgets/status_views.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ArticleDetailBloc(articleRepository: sl())
            ..add(ArticleDetailRequested(articleId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Article')),
        body: BlocBuilder<ArticleDetailBloc, ArticleDetailState>(
          // Loaded→loaded emits only change engagement fields, which
          // _EngagementRow renders through its own BlocSelector — the rest
          // of the body is static once loaded.
          buildWhen: (previous, current) =>
              previous is! ArticleDetailLoaded ||
              current is! ArticleDetailLoaded,
          builder: (context, state) {
            return switch (state) {
              ArticleDetailInitial() || ArticleDetailLoading() => const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading article',
                ),
              ),
              ArticleDetailError(:final message, :final isOffline) => Column(
                children: [
                  const OfflineBanner(),
                  Expanded(
                    child: ErrorView(
                      message: message,
                      icon: isOffline
                          ? Icons.cloud_off_outlined
                          : Icons.error_outline,
                      onRetry: () => context.read<ArticleDetailBloc>().add(
                        ArticleDetailRequested(articleId),
                      ),
                    ),
                  ),
                ],
              ),
              ArticleDetailGone() => const EmptyView(
                title: 'This article is no longer available',
                subtitle: 'It was removed by its publisher.',
                icon: Icons.unpublished_outlined,
              ),
              final ArticleDetailLoaded loaded => _DetailBody(loaded: loaded),
            };
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.loaded});

  final ArticleDetailLoaded loaded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = loaded.detail;
    final article = detail.article;

    return Column(
      children: [
        OfflineBanner(showStale: loaded.isStale),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              if (article.imageUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppNetworkImage(url: article.imageUrl!),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${article.source} · ${relativeTime(article.publishedAt)}'
                      '${detail.readTimeMinutes != null ? ' · ${detail.readTimeMinutes} min read' : ''}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (detail.updatedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Updated ${relativeTime(detail.updatedAt!)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _AuthorRow(article: article, bio: detail.authorBio),
                    const Divider(height: 32),
                    for (final block in detail.body) _Block(block: block),
                    if (article.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in article.tags)
                            Chip(
                              label: Text('#$tag'),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    const _EngagementRow(),
                    if (loaded.related.isNotEmpty) ...[
                      const Divider(height: 32),
                      Text(
                        'Related stories',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final related in loaded.related)
                        _RelatedTile(article: related),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block});

  final ContentBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: switch (block) {
        ParagraphBlock(:final text) => Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        QuoteBlock(:final text) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4),
            ),
          ),
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        ImageBlock(:final url) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: AppNetworkImage(url: url),
          ),
        ),
      },
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.article, this.bio});

  final Article article;
  final String? bio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: article.authorAvatar != null
              ? CachedNetworkImageProvider(article.authorAvatar!)
              : null,
          child: article.authorAvatar == null
              ? Text(
                  article.authorName.isNotEmpty ? article.authorName[0] : '?',
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.authorName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (bio != null)
                Text(
                  bio!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EngagementRow extends StatelessWidget {
  const _EngagementRow();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ArticleDetailBloc, ArticleDetailState, Article?>(
      selector: (state) =>
          state is ArticleDetailLoaded ? state.detail.article : null,
      builder: (context, article) {
        if (article == null) return const SizedBox.shrink();
        return _EngagementRowContent(article: article);
      },
    );
  }
}

class _EngagementRowContent extends StatelessWidget {
  const _EngagementRowContent({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final engagement = context.read<EngagementBloc>();
    return Row(
      children: [
        FilledButton.tonalIcon(
          onPressed: () => engagement.add(EngagementLikeToggled(article)),
          icon: Icon(
            article.isLiked ? Icons.favorite : Icons.favorite_border,
            color: article.isLiked ? theme.colorScheme.error : null,
          ),
          label: Text(
            '${article.likes}',
            semanticsLabel: article.isLiked
                ? 'Unlike, ${article.likes} likes'
                : 'Like, ${article.likes} likes',
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.tonalIcon(
          onPressed: () => engagement.add(EngagementBookmarkToggled(article)),
          icon: Icon(
            article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          ),
          label: Text(article.isBookmarked ? 'Saved' : 'Save'),
        ),
        const Spacer(),
        Icon(
          Icons.mode_comment_outlined,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${article.comments}',
          style: theme.textTheme.labelLarge,
          semanticsLabel: '${article.comments} comments',
        ),
      ],
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: article.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(
                url: article.imageUrl!,
                width: 56,
                height: 56,
              ),
            )
          : const Icon(Icons.article_outlined),
      title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(article.source),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ArticleDetailPage(articleId: article.id),
        ),
      ),
    );
  }
}
