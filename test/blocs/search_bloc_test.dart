import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vlau_assessment/domain/entities/paged_articles.dart';
import 'package:vlau_assessment/domain/services/article_update_bus.dart';
import 'package:vlau_assessment/presentation/blocs/search/search_bloc.dart';

import '../helpers.dart';

void main() {
  late MockSearchRepository repository;
  late ArticleUpdateBus bus;

  const debounce = Duration(milliseconds: 50);

  setUp(() {
    repository = MockSearchRepository();
    bus = ArticleUpdateBus();
    registerFallbackValue(Duration.zero);
  });

  tearDown(() => bus.dispose());

  SearchBloc buildBloc() =>
      SearchBloc(searchRepository: repository, bus: bus, debounce: debounce);

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

  test('clearing both filters costs exactly one search', () async {
    when(
      () => repository.sources(topicId: any(named: 'topicId')),
    ).thenAnswer((_) async => ['TechWire', 'Future Stack']);
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
    bloc.add(const SearchTopicFilterChanged('t_technology'));
    await Future<void>.delayed(debounce * 2);
    bloc.add(const SearchSourceFilterChanged('TechWire'));
    await Future<void>.delayed(debounce * 2);

    // The opening unfiltered search matches the same verify below.
    clearInteractions(repository);
    bloc.add(const SearchFiltersCleared());
    await Future<void>.delayed(debounce * 3);

    expect(bloc.state.topicId, isNull);
    expect(bloc.state.source, isNull);
    verify(
      () => repository.search('flutter', topicId: null, source: null),
    ).called(1);

    await bloc.close();
  });

  test('re-selecting the active topic does not refetch', () async {
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
    bloc.add(const SearchQueryChanged('flutter'));
    await Future<void>.delayed(debounce * 3);
    bloc.add(const SearchTopicFilterChanged('t_technology'));
    await Future<void>.delayed(debounce * 2);

    clearInteractions(repository);
    bloc.add(const SearchTopicFilterChanged('t_technology'));
    await Future<void>.delayed(debounce * 3);

    verifyNever(
      () => repository.search(
        any(),
        topicId: any(named: 'topicId'),
        source: any(named: 'source'),
      ),
    );

    await bloc.close();
  });
}
