import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/core/error/app_exception.dart';
import 'package:vlau_assessment/domain/entities/article.dart';
import 'package:vlau_assessment/domain/repositories/bookmark_repository.dart';
import 'package:vlau_assessment/domain/repositories/feed_repository.dart';
import 'package:vlau_assessment/domain/repositories/reaction_repository.dart';
import 'package:vlau_assessment/presentation/blocs/connectivity/connectivity_cubit.dart';
import 'package:vlau_assessment/presentation/blocs/engagement/engagement_bloc.dart';
import 'package:vlau_assessment/presentation/blocs/feed/feed_bloc.dart';
import 'package:vlau_assessment/presentation/pages/feed_page.dart';
import 'package:vlau_assessment/presentation/widgets/feed_skeleton.dart';
import 'package:vlau_assessment/presentation/widgets/status_views.dart';

import '../helpers.dart';

class MockReactionRepository extends Mock implements ReactionRepository {}

class MockBookmarkRepository extends Mock implements BookmarkRepository {}

void main() {
  late MockFeedRepository feedRepository;
  late MockSearchRepository searchRepository;
  late FakeConnectivity connectivity;

  setUp(() {
    feedRepository = MockFeedRepository();
    searchRepository = MockSearchRepository();
    connectivity = FakeConnectivity();
    when(() => searchRepository.topics()).thenAnswer((_) async => const []);
  });

  tearDown(() async {
    await connectivity.dispose();
  });

  void stubFeed(List<Article> articles) {
    when(
      () => feedRepository.watchFeed(topicId: any(named: 'topicId')),
    ).thenAnswer((_) => Stream.value(articles));
  }

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConnectivityCubit(
            connectivity: connectivity,
            syncService: FakeSyncService(),
          ),
        ),
        BlocProvider(
          create: (_) => EngagementBloc(
            reactionRepository: MockReactionRepository(),
            bookmarkRepository: MockBookmarkRepository(),
          ),
        ),
        BlocProvider(
          create: (_) => FeedBloc(
            feedRepository: feedRepository,
            searchRepository: searchRepository,
          )..add(const FeedStarted()),
        ),
      ],
      child: const MaterialApp(home: FeedPage()),
    );
  }

  testWidgets(
    'primary transition: loading skeleton, then the loaded article list',
    (tester) async {
      final gate = Completer<FeedLoadResult>();
      when(
        () => feedRepository.loadFirstPage(topicId: any(named: 'topicId')),
      ).thenAnswer((_) => gate.future);
      stubFeed([makeArticle('a1'), makeArticle('a2')]);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(FeedSkeleton), findsOneWidget);

      gate.complete(const FeedLoadResult(hasMore: true));
      await tester.pump();
      await tester.pump();

      expect(find.byType(FeedSkeleton), findsNothing);
      expect(find.text('Title a1'), findsOneWidget);
      expect(find.text('Title a2'), findsOneWidget);
    },
  );

  testWidgets('failure state shows a friendly error with a working retry', (
    tester,
  ) async {
    var calls = 0;
    when(
      () => feedRepository.loadFirstPage(topicId: any(named: 'topicId')),
    ).thenAnswer((_) async {
      if (++calls == 1) throw const NetworkException();
      return const FeedLoadResult(hasMore: false);
    });
    stubFeed([makeArticle('a1')]);

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.text('Title a1'), findsOneWidget);
  });

  testWidgets('empty state is distinct from error and loading', (tester) async {
    when(
      () => feedRepository.loadFirstPage(topicId: any(named: 'topicId')),
    ).thenAnswer((_) async => const FeedLoadResult(hasMore: false));
    stubFeed(const []);

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump();

    expect(find.text('No stories here yet'), findsOneWidget);
    expect(find.byType(ErrorView), findsNothing);
    expect(find.byType(FeedSkeleton), findsNothing);
  });
}
