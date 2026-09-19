import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/error/app_exception.dart';
import 'package:vlau_assessment/domain/entities/paged_articles.dart';
import 'package:vlau_assessment/domain/repositories/feed_repository.dart';
import 'package:vlau_assessment/domain/services/article_update_bus.dart';
import 'package:vlau_assessment/presentation/blocs/feed/feed_bloc.dart';

import '../helpers.dart';

void main() {
  late MockFeedRepository feedRepository;
  late MockSearchRepository searchRepository;
  late ArticleUpdateBus bus;

  final page1 = PagedArticles(
    items: [makeArticle('a1'), makeArticle('a2')],
    nextCursor: 'feed_2',
    total: 4,
  );
  final page2 = PagedArticles(
    items: [makeArticle('a2'), makeArticle('a3')],
    nextCursor: null,
    total: 4,
  );

  setUp(() {
    feedRepository = MockFeedRepository();
    searchRepository = MockSearchRepository();
    bus = ArticleUpdateBus();
    when(() => searchRepository.topics()).thenAnswer((_) async => const []);
  });

  tearDown(() => bus.dispose());

  FeedBloc buildBloc() => FeedBloc(
    feedRepository: feedRepository,
    searchRepository: searchRepository,
    bus: bus,
  );

  group('initial load', () {
    blocTest<FeedBloc, FeedState>(
      'emits [loading, success] with the first page',
      build: () {
        when(
          () => feedRepository.firstPage(topicId: any(named: 'topicId')),
        ).thenAnswer((_) async => page1);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const FeedStarted()),
      expect: () => [
        const FeedState(status: FeedStatus.loading),
        isA<FeedState>()
            .having((s) => s.status, 'status', FeedStatus.success)
            .having((s) => s.articles.map((a) => a.id), 'ids', ['a1', 'a2'])
            .having((s) => s.nextCursor, 'nextCursor', 'feed_2'),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'emits [loading, failure] when nothing can be loaded',
      build: () {
        when(
          () => feedRepository.firstPage(topicId: any(named: 'topicId')),
        ).thenThrow(const NetworkException());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const FeedStarted()),
      expect: () => [
        const FeedState(status: FeedStatus.loading),
        isA<FeedState>().having((s) => s.status, 'status', FeedStatus.failure),
      ],
    );
  });

  group('pagination', () {
    blocTest<FeedBloc, FeedState>(
      'appends the next page and deduplicates by id',
      build: () {
        when(
          () =>
              feedRepository.nextPage('feed_2', topicId: any(named: 'topicId')),
        ).thenAnswer((_) async => page2);
        return buildBloc();
      },
      seed: () => FeedState(
        status: FeedStatus.success,
        articles: page1.items,
        nextCursor: 'feed_2',
      ),
      act: (bloc) => bloc.add(const FeedNextPageRequested()),
      expect: () => [
        isA<FeedState>().having((s) => s.isLoadingMore, 'loadingMore', true),
        isA<FeedState>()
            .having((s) => s.articles.map((a) => a.id), 'ids', [
              'a1',
              'a2',
              'a3',
            ])
            .having((s) => s.nextCursor, 'nextCursor', null)
            .having((s) => s.isLoadingMore, 'loadingMore', false),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'keeps the loaded list and flags a page-level failure, then retries',
      build: () {
        var calls = 0;
        when(
          () =>
              feedRepository.nextPage('feed_2', topicId: any(named: 'topicId')),
        ).thenAnswer((_) async {
          if (++calls == 1) throw const ServerException();
          return page2;
        });
        return buildBloc();
      },
      seed: () => FeedState(
        status: FeedStatus.success,
        articles: page1.items,
        nextCursor: 'feed_2',
      ),
      act: (bloc) async {
        bloc.add(const FeedNextPageRequested());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const FeedNextPageRequested());
      },
      expect: () => [
        isA<FeedState>().having((s) => s.isLoadingMore, 'loadingMore', true),
        isA<FeedState>()
            .having((s) => s.loadMoreFailed, 'loadMoreFailed', true)
            .having((s) => s.articles.length, 'list preserved', 2),
        isA<FeedState>().having((s) => s.isLoadingMore, 'loadingMore', true),
        isA<FeedState>()
            .having((s) => s.articles.map((a) => a.id), 'ids after retry', [
              'a1',
              'a2',
              'a3',
            ])
            .having((s) => s.loadMoreFailed, 'loadMoreFailed', false),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'ignores a page request when there is no next cursor',
      build: buildBloc,
      seed: () => FeedState(
        status: FeedStatus.success,
        articles: page1.items,
        nextCursor: null,
      ),
      act: (bloc) => bloc.add(const FeedNextPageRequested()),
      expect: () => const <FeedState>[],
      verify: (_) => verifyNever(
        () => feedRepository.nextPage(any(), topicId: any(named: 'topicId')),
      ),
    );
  });

  group('refresh', () {
    blocTest<FeedBloc, FeedState>(
      'prepends new items without duplicates and drops deleted articles',
      build: () {
        when(
          () => feedRepository.refresh(topicId: any(named: 'topicId')),
        ).thenAnswer(
          (_) async => FeedRefreshResult(
            head: PagedArticles(
              items: [makeArticle('a0'), makeArticle('a1', likes: 99)],
              nextCursor: 'feed_2',
            ),
            deletedIds: const ['a2'],
          ),
        );
        return buildBloc();
      },
      seed: () => FeedState(
        status: FeedStatus.success,
        articles: [makeArticle('a1'), makeArticle('a2'), makeArticle('a3')],
        nextCursor: 'feed_4',
      ),
      act: (bloc) => bloc.add(const FeedRefreshRequested()),
      expect: () => [
        isA<FeedState>().having((s) => s.isRefreshing, 'isRefreshing', true),
        isA<FeedState>()
            .having((s) => s.articles.map((a) => a.id), 'ids', [
              'a0',
              'a1',
              'a3',
            ])
            .having((s) => s.articles[1].likes, 'a1 updated in place', 99)
            .having((s) => s.nextCursor, 'scroll window kept', 'feed_4')
            .having((s) => s.notice, 'notice', '1 new story'),
        isA<FeedState>().having((s) => s.isRefreshing, 'isRefreshing', false),
      ],
    );
  });
}
