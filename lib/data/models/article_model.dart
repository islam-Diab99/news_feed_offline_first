import '../../domain/entities/article.dart';

abstract final class ArticleModel {
  static Article fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return Article(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      source: json['source'] as String? ?? '',
      authorName: author?['name'] as String? ?? 'Unknown',
      authorAvatar: author?['avatar'] as String?,
      topicId: json['topicId'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      imageUrl: json['image'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  static Map<String, dynamic> toJson(Article article) => {
    'id': article.id,
    'title': article.title,
    'summary': article.summary,
    'source': article.source,
    'author': {
      'name': article.authorName,
      if (article.authorAvatar != null) 'avatar': article.authorAvatar,
    },
    'topicId': article.topicId,
    'publishedAt': article.publishedAt.toUtc().toIso8601String(),
    if (article.imageUrl != null) 'image': article.imageUrl,
    'tags': article.tags,
    'likes': article.likes,
    'comments': article.comments,
    'isLiked': article.isLiked,
    'isBookmarked': article.isBookmarked,
    'version': article.version,
  };
}
