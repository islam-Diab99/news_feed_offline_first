import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/articles/domain/entities/article.dart';
import 'package:vlau_assessment/core/error/app_exception.dart';
import 'package:vlau_assessment/features/feed/domain/feed_repository.dart';
import 'package:vlau_assessment/features/feed/presentation/bloc/feed_bloc.dart';

import '../../helpers.dart';

void main() {
  late MockFeedRepository feedRepository;
  late MockTopicRepository topicRepository;
  late StreamController<List<Article>> feed;

  setUp(() {
    feedRepository = MockFeedRepository();
    topicRepository = MockTopicRepository();
    feed = StreamController<List<Article>>.broadcast();
    when(() => topicRepository.topics()).thenAnswer((_) async => const []);
    when(
      () => feedRepository.watchFeed(topicId: any(named: 'topicId')),
    ).thenAnswer((_) => feed.stream);
  });

  tearDown(() => feed.close());

  FeedBloc buildBloc() => FeedBloc(
    feedRepository: feedRepository,
    topicRepository: topicRepository,
  );

  final loaded = FeedState(
    status: FeedStatus.success,
    articles: [makeArticle('a1'), makeArticle('a2')],
    hasMore: true,
  );

  group('initial load', () {
    blocTest<FeedBloc, FeedState>(
      'loads page 1, then shows the stored feed',
      build: () {
        when(
          () => feedRepository.loadFirstPage(topicId: any(named: 'topicId')),
        ).thenAnswer((_) async => const FeedLoadResult(hasMore: true));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedStarted());
        await pumpEventQueue();
        feed.add([makeArticle('a1'), makeArticle('a2')]);
      },
      expect: () => [
        const FeedState(status: FeedStatus.loading),
        isA<FeedState>().having((s) => s.hasMore, 'hasMore', true),
        isA<FeedState>()
            .having((s) => s.status, 'status', FeedStatus.success)
            .having((s) => s.articles.map((a) => a.id), 'ids', ['a1', 'a2']),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'emits [loading, failure] when nothing can be loaded',
      build: () {
        when(
          () => feedRepository.loadFirstPage(topicId: any(named: 'topicId')),
        ).thenThrow(const NetworkException());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const FeedStarted()),
      expect: () => [
        const FeedState(status: FeedStatus.loading),
        isA<FeedState>().having((s) => s.status, 'status', FeedStatus.failure),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'a change anywhere in the store reaches the list',
      build: () {
        when(
          () => feedRepository.loadFirstPage(topicId: any(named: 'topicId')),
        ).thenAnswer((_) async => const FeedLoadResult(hasMore: true));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedStarted());
        await pumpEventQueue();
        feed.add([makeArticle('a1')]);
        await pumpEventQueue();
        feed.add([makeArticle('a1', likes: 11, isLiked: true)]);
      },
      skip: 2,
      expect: () => [
        isA<FeedState>().having((s) => s.articles.single.likes, 'likes', 10),
        isA<FeedState>().having((s) => s.articles.single.likes, 'likes', 11),
      ],
    );
  });

  group('pagination', () {
    blocTest<FeedBloc, FeedState>(
      'loads the next page and tracks whether more remain',
      build: () {
        when(
          () => feedRepository.loadNextPage(topicId: any(named: 'topicId')),
        ).thenAnswer((_) async => const FeedLoadResult(hasMore: false));
        return buildBloc();
      },
      seed: () => loaded,
      act: (bloc) => bloc.add(const FeedNextPageRequested()),
      expect: () => [
        isA<FeedState>().having((s) => s.isLoadingMore, 'loadingMore', true),
        isA<FeedState>()
            .having((s) => s.isLoadingMore, 'loadingMore', false)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'keeps the loaded list and flags a page-level failure, then retries',
      build: () {
        var calls = 0;
        when(
          () => feedRepository.loadNextPage(topicId: any(named: 'topicId')),
        ).thenAnswer((_) async {
          if (++calls == 1) throw const ServerException();
          return const FeedLoadResult(hasMore: false);
        });
        return buildBloc();
      },
      seed: () => loaded,
      act: (bloc) async {
        bloc.add(const FeedNextPageRequested());
        await pumpEventQueue();
        bloc.add(const FeedNextPageRequested());
      },
      expect: () => [
        isA<FeedState>().having((s) => s.isLoadingMore, 'loadingMore', true),
        isA<FeedState>()
            .having((s) => s.loadMoreFailed, 'loadMoreFailed', true)
            .having((s) => s.articles.length, 'list preserved', 2),
        isA<FeedState>().having((s) => s.isLoadingMore, 'loadingMore', true),
        isA<FeedState>()
            .having((s) => s.loadMoreFailed, 'loadMoreFailed', false)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'ignores a page request when there is nothing more',
      build: buildBloc,
      seed: () =>
          FeedState(status: FeedStatus.success, articles: [makeArticle('a1')]),
      act: (bloc) => bloc.add(const FeedNextPageRequested()),
      expect: () => const <FeedState>[],
      verify: (_) => verifyNever(
        () => feedRepository.loadNextPage(topicId: any(named: 'topicId')),
      ),
    );
  });

  group('refresh', () {
    blocTest<FeedBloc, FeedState>(
      'announces new stories and clears the stale flag',
      build: () {
        when(
          () => feedRepository.refresh(topicId: any(named: 'topicId')),
        ).thenAnswer((_) async => const FeedRefreshResult(newStories: 1));
        return buildBloc();
      },
      seed: () => loaded,
      act: (bloc) => bloc.add(const FeedRefreshRequested()),
      expect: () => [
        isA<FeedState>().having((s) => s.isRefreshing, 'isRefreshing', true),
        isA<FeedState>()
            .having((s) => s.notice, 'notice', '1 new story')
            .having((s) => s.isStale, 'isStale', false),
        isA<FeedState>().having((s) => s.isRefreshing, 'isRefreshing', false),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'offline, keeps the saved stories and says so',
      build: () {
        when(
          () => feedRepository.refresh(topicId: any(named: 'topicId')),
        ).thenThrow(const NetworkException());
        return buildBloc();
      },
      seed: () => loaded,
      act: (bloc) => bloc.add(const FeedRefreshRequested()),
      expect: () => [
        isA<FeedState>().having((s) => s.isRefreshing, 'isRefreshing', true),
        isA<FeedState>()
            .having((s) => s.isStale, 'isStale', true)
            .having((s) => s.articles.length, 'list kept', 2),
        isA<FeedState>().having((s) => s.isRefreshing, 'isRefreshing', false),
      ],
    );
  });
}
