import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.authorName,
    this.authorAvatar,
    required this.topicId,
    required this.publishedAt,
    this.imageUrl,
    this.tags = const [],
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isBookmarked,
    this.version = 1,
  });

  final String id;
  final String title;
  final String summary;
  final String source;
  final String authorName;
  final String? authorAvatar;
  final String topicId;
  final DateTime publishedAt;
  final String? imageUrl;
  final List<String> tags;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isBookmarked;

  final int version;

  Article copyWith({
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isBookmarked,
    int? version,
  }) {
    return Article(
      id: id,
      title: title,
      summary: summary,
      source: source,
      authorName: authorName,
      authorAvatar: authorAvatar,
      topicId: topicId,
      publishedAt: publishedAt,
      imageUrl: imageUrl,
      tags: tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
    id,
    likes,
    comments,
    isLiked,
    isBookmarked,
    version,
    title,
    summary,
  ];
}
