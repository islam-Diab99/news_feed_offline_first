import '../../domain/entities/article_detail.dart';
import 'article_model.dart';

abstract final class ArticleDetailModel {
  static ArticleDetail fromJson(Map<String, dynamic> json) {
    return ArticleDetail(
      article: ArticleModel.fromJson(json),
      body: bodyFromJson(json['body'] as List? ?? const []),
      authorBio: (json['author'] as Map<String, dynamic>?)?['bio'] as String?,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      readTimeMinutes: (json['readTimeMinutes'] as num?)?.toInt(),
      relatedIds: (json['related'] as List?)?.cast<String>() ?? const [],
    );
  }

  static List<ContentBlock> bodyFromJson(List blocks) {
    return blocks
        .whereType<Map<String, dynamic>>()
        .map<ContentBlock?>(
          (block) => switch (block['type']) {
            'paragraph' => ParagraphBlock(block['text'] as String? ?? ''),
            'image' => ImageBlock(block['url'] as String? ?? ''),
            'quote' => QuoteBlock(block['text'] as String? ?? ''),
            _ => null,
          },
        )
        .whereType<ContentBlock>()
        .toList();
  }

  static List<Map<String, dynamic>> bodyToJson(List<ContentBlock> body) => body
      .map(
        (block) => switch (block) {
          ParagraphBlock(:final text) => {'type': 'paragraph', 'text': text},
          ImageBlock(:final url) => {'type': 'image', 'url': url},
          QuoteBlock(:final text) => {'type': 'quote', 'text': text},
        },
      )
      .toList();

  static Map<String, dynamic> toJson(ArticleDetail detail) => {
    ...ArticleModel.toJson(detail.article),
    'body': bodyToJson(detail.body),
    'author': {
      'name': detail.article.authorName,
      if (detail.article.authorAvatar != null)
        'avatar': detail.article.authorAvatar,
      if (detail.authorBio != null) 'bio': detail.authorBio,
    },
    if (detail.updatedAt != null)
      'updatedAt': detail.updatedAt!.toUtc().toIso8601String(),
    if (detail.readTimeMinutes != null)
      'readTimeMinutes': detail.readTimeMinutes,
    'related': detail.relatedIds,
  };
}
