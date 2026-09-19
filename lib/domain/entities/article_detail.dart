import 'package:equatable/equatable.dart';

import 'article.dart';

sealed class ContentBlock extends Equatable {
  const ContentBlock();
}

class ParagraphBlock extends ContentBlock {
  const ParagraphBlock(this.text);
  final String text;

  @override
  List<Object?> get props => [text];
}

class ImageBlock extends ContentBlock {
  const ImageBlock(this.url);
  final String url;

  @override
  List<Object?> get props => [url];
}

class QuoteBlock extends ContentBlock {
  const QuoteBlock(this.text);
  final String text;

  @override
  List<Object?> get props => [text];
}

class ArticleDetail extends Equatable {
  const ArticleDetail({
    required this.article,
    required this.body,
    this.authorBio,
    this.updatedAt,
    this.readTimeMinutes,
    this.relatedIds = const [],
  });

  final Article article;
  final List<ContentBlock> body;
  final String? authorBio;
  final DateTime? updatedAt;
  final int? readTimeMinutes;
  final List<String> relatedIds;

  ArticleDetail withArticle(Article article) => ArticleDetail(
    article: article,
    body: body,
    authorBio: authorBio,
    updatedAt: updatedAt,
    readTimeMinutes: readTimeMinutes,
    relatedIds: relatedIds,
  );

  @override
  List<Object?> get props => [article, body, relatedIds];
}

sealed class ArticleDetailResult extends Equatable {
  const ArticleDetailResult();

  @override
  List<Object?> get props => [];
}

class ArticleDetailAvailable extends ArticleDetailResult {
  const ArticleDetailAvailable(
    this.detail, {
    this.related = const [],
    this.isStale = false,
  });

  final ArticleDetail detail;
  final List<Article> related;
  final bool isStale;

  @override
  List<Object?> get props => [detail, related, isStale];
}

class ArticleDetailUnavailable extends ArticleDetailResult {
  const ArticleDetailUnavailable(this.articleId, {this.reason});

  final String articleId;
  final String? reason;

  @override
  List<Object?> get props => [articleId, reason];
}
