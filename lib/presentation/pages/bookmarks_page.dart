import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/bookmarks/bookmarks_bloc.dart';
import '../widgets/offline_banner.dart';
import '../widgets/paginated_article_list.dart';
import '../widgets/status_views.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: BlocBuilder<BookmarksBloc, BookmarksState>(
        builder: (context, state) {
          return Column(
            children: [
              const OfflineBanner(),
              Expanded(child: _BookmarksBody(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _BookmarksBody extends StatelessWidget {
  const _BookmarksBody({required this.state});

  final BookmarksState state;

  @override
  Widget build(BuildContext context) {
    return PaginatedArticleList(
      status: switch (state.status) {
        BookmarksStatus.initial ||
        BookmarksStatus.loading => ArticleListStatus.loading,
        BookmarksStatus.failure => ArticleListStatus.failure,
        BookmarksStatus.success => ArticleListStatus.success,
      },
      articles: state.articles,
      loadingView: const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading bookmarks'),
      ),
      errorBuilder: (_) => ErrorView(
        message: state.errorMessage ?? 'Could not load bookmarks.',
        onRetry: () =>
            context.read<BookmarksBloc>().add(const BookmarksRequested()),
      ),
      emptyBuilder: (_) => const EmptyView(
        title: 'No bookmarks yet',
        subtitle:
            'Save stories with the bookmark icon and read them anytime — even offline.',
        icon: Icons.bookmark_border,
      ),
    );
  }
}
