import 'package:equatable/equatable.dart';

import 'article.dart';

class PagedArticles extends Equatable {
  const PagedArticles({
    required this.items,
    this.nextCursor,
    this.total,
    this.isStale = false,
  });

  final List<Article> items;
  final String? nextCursor;
  final int? total;
  final bool isStale;

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [items, nextCursor, total, isStale];
}
