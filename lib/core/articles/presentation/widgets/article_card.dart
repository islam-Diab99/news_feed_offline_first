import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/relative_time.dart';
import '../../../widgets/app_network_image.dart';
import '../../domain/entities/article.dart';
import '../engagement/engagement_bloc.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.topicName,
  });

  final Article article;
  final VoidCallback onTap;
  final String? topicName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: AppNetworkImage(url: article.imageUrl!),
              ),
            MergeSemantics(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            article.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (topicName != null) ...[
                          Text(' · ', style: theme.textTheme.labelMedium),
                          Text(topicName!, style: theme.textTheme.labelMedium),
                        ],
                        const Spacer(),
                        Text(
                          relativeTime(article.publishedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Row(
                children: [
                  _LikeButton(article: article),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.mode_comment_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${article.comments}',
                    style: theme.textTheme.labelMedium,
                    semanticsLabel: '${article.comments} comments',
                  ),
                  const Spacer(),
                  _BookmarkButton(article: article),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: () =>
          context.read<EngagementBloc>().add(EngagementLikeToggled(article)),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          article.isLiked ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(article.isLiked),
          size: 20,
          color: article.isLiked
              ? theme.colorScheme.error
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      label: Text(
        '${article.likes}',
        semanticsLabel: article.isLiked
            ? 'Unlike, ${article.likes} likes'
            : 'Like, ${article.likes} likes',
      ),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurfaceVariant,
        minimumSize: const Size(48, 40),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: article.isBookmarked
          ? 'Remove bookmark'
          : 'Bookmark this article',
      onPressed: () => context.read<EngagementBloc>().add(
        EngagementBookmarkToggled(article),
      ),
      icon: Icon(
        article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: article.isBookmarked
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
    );
  }
}
