import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/domain/entities/paged_articles.dart';
import 'package:vlau_assessment/domain/entities/article.dart';
import 'package:vlau_assessment/presentation/blocs/search/search_bloc.dart';

import '../helpers.dart';

void main() {
  late MockSearchRepository repository;
  late MockArticleRepository articles;

  const debounce = Duration(milliseconds: 50);

  setUp(() {
    repository = MockSearchRepository();
    articles = MockArticleRepository();
    registerFallbackValue(<String>[]);
    when(
      () => articles.watchArticles(any()),
    ).thenAnswer((_) => const Stream.empty());
  });

  SearchBloc buildBloc() => SearchBloc(
    searchRepository: repository,
    articleRepository: articles,
    debounce: debounce,
  );

  PagedArticles resultFor(String id) =>
      PagedArticles(items: [makeArticle(id)], total: 1);

  test(
    'debounces keystrokes: only the final query hits the repository',
    () async {
      when(
        () => repository.search(
          any(),
          topicId: any(named: 'topicId'),
          source: any(named: 'source'),
        ),
      ).thenAnswer((_) async => resultFor('a_flutter'));

      final bloc = buildBloc();
      bloc
        ..add(const SearchQueryChanged('f'))
        ..add(const SearchQueryChanged('fl'))
        ..add(const SearchQueryChanged('flutter'));

      await Future<void>.delayed(debounce * 4);

      verify(
        () => repository.search(
          'flutter',
          topicId: any(named: 'topicId'),
          source: any(named: 'source'),
        ),
      ).called(1);
      verifyNever(
        () => repository.search(
          'f',
          topicId: any(named: 'topicId'),
          source: any(named: 'source'),
        ),
      );
      verifyNever(
        () => repository.search(
          'fl',
          topicId: any(named: 'topicId'),
          source: any(named: 'source'),
        ),
      );
      expect(bloc.state.results.single.id, 'a_flutter');

      await bloc.close();
    },
  );

  test('a stale in-flight request cannot overwrite newer results', () async {
    final slowFirst = Completer<PagedArticles>();
    when(
      () => repository.search(
        'first',
        topicId: any(named: 'topicId'),
        source: any(named: 'source'),
      ),
    ).thenAnswer((_) => slowFirst.future);
    when(
      () => repository.search(
        'second',
        topicId: any(named: 'topicId'),
        source: any(named: 'source'),
      ),
    ).thenAnswer((_) async => resultFor('a_second'));

    final bloc = buildBloc();

    bloc.add(const SearchQueryChanged('first'));
    await Future<void>.delayed(debounce * 2);

    bloc.add(const SearchQueryChanged('second'));
    await Future<void>.delayed(debounce * 3);

    slowFirst.complete(resultFor('a_stale'));
    await Future<void>.delayed(debounce);

    expect(bloc.state.status, SearchStatus.success);
    expect(bloc.state.results.single.id, 'a_second');
    expect(bloc.state.query, 'second');

    await bloc.close();
  });

  test(
    'clearing the query returns to idle without hitting the repository',
    () async {
      final bloc = buildBloc();
      bloc.add(const SearchQueryChanged('   '));
      await Future<void>.delayed(debounce * 3);

      expect(bloc.state.status, SearchStatus.idle);
      verifyNever(
        () => repository.search(
          any(),
          topicId: any(named: 'topicId'),
          source: any(named: 'source'),
        ),
      );

      await bloc.close();
    },
  );

  test('filters are preserved across query changes', () async {
    when(
      () => repository.sources(topicId: any(named: 'topicId')),
    ).thenAnswer((_) async => ['TechWire']);
    when(
      () => repository.search(
        any(),
        topicId: any(named: 'topicId'),
        source: any(named: 'source'),
      ),
    ).thenAnswer((_) async => resultFor('a1'));

    final bloc = buildBloc();
    bloc.add(const SearchTopicFilterChanged('t_technology'));
    await Future<void>.delayed(debounce);
    bloc.add(const SearchQueryChanged('flutter'));
    await Future<void>.delayed(debounce * 3);

    verify(
      () => repository.search('flutter', topicId: 't_technology', source: null),
    ).called(1);

    await bloc.close();
  });

  test('results follow later changes to the same articles', () async {
    final changes = StreamController<List<Article>>();
    when(
      () => articles.watchArticles(['a1']),
    ).thenAnswer((_) => changes.stream);
    when(
      () => repository.search(
        any(),
        topicId: any(named: 'topicId'),
        source: any(named: 'source'),
      ),
    ).thenAnswer((_) async => resultFor('a1'));

    final bloc = buildBloc();
    bloc.add(const SearchQueryChanged('flutter'));
    await Future<void>.delayed(debounce * 3);

    changes.add([makeArticle('a1', likes: 11, isLiked: true)]);
    await pumpEventQueue();

    expect(bloc.state.results.single.isLiked, isTrue);
    expect(bloc.state.results.single.likes, 11);

    await bloc.close();
    await changes.close();
  });
}
