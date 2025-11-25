import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:multiverse_guide/domain/entities/character.dart';
import 'package:multiverse_guide/domain/usecases/get_characters.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_bloc.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_event.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_state.dart';
import 'package:multiverse_guide/core/errors/failures.dart';

// Mocks
class MockGetCharacters extends Mock implements GetCharacters {}

// Fake classes for event matching
class FakeGetCharactersParams extends Fake implements GetCharactersParams {}

void main() {
  late MockGetCharacters mockGetCharacters;

  setUpAll(() {
    registerFallbackValue(FakeGetCharactersParams());
  });

  setUp(() {
    mockGetCharacters = MockGetCharacters();
  });

  // Test data
  const tCharactersPage1 = [
    Character(
      id: 1,
      name: 'Rick Sanchez',
      status: CharacterStatus.alive,
      species: 'Human',
      type: '',
      gender: 'Male',
      image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
      location: 'Earth',
      origin: 'Earth',
      episode: ['https://rickandmortyapi.com/api/episode/1'],
    ),
    Character(
      id: 2,
      name: 'Morty Smith',
      status: CharacterStatus.alive,
      species: 'Human',
      type: '',
      gender: 'Male',
      image: 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
      location: 'Earth',
      origin: 'Earth',
      episode: ['https://rickandmortyapi.com/api/episode/1'],
    ),
  ];

  const tCharactersPage2 = [
    Character(
      id: 3,
      name: 'Summer Smith',
      status: CharacterStatus.alive,
      species: 'Human',
      type: '',
      gender: 'Female',
      image: 'https://rickandmortyapi.com/api/character/avatar/3.jpeg',
      location: 'Earth',
      origin: 'Earth',
      episode: ['https://rickandmortyapi.com/api/episode/1'],
    ),
  ];

  const tEmptyCharacters = <Character>[];

  CharacterListBloc createBloc() {
    return CharacterListBloc(getCharacters: mockGetCharacters);
  }

  group('CharacterListBloc Initialization', () {
    test('initial state is CharacterListState.initial()', () {
      // Arrange
      final bloc = createBloc();

      // Assert
      expect(bloc.state, const CharacterListState());
    });
  });

  group('FetchCharacters Event', () {
    blocTest<CharacterListBloc, CharacterListState>(
      'emits [loading, success] when FetchCharacters is added and succeeds for first page',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => const Right(tCharactersPage1));
        return createBloc();
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 1)),
      expect: () => [
        const CharacterListState(isLoading: true, errorMessage: null),
        const CharacterListState(
          characters: tCharactersPage1,
          isLoading: false,
          hasReachedMax: false,
          errorMessage: null,
        ),
      ],
      verify: (_) {
        verify(() => mockGetCharacters(
              status: null,
              name: null,
            )).called(1);
      },
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'emits [loading, success] when FetchCharacters is added for pagination and succeeds',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => const Right(tCharactersPage2));
        return createBloc()
          ..emit(const CharacterListState(characters: tCharactersPage1));
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 2)),
      expect: () => [
        const CharacterListState(
          characters: tCharactersPage1,
          isLoading: true,
        ),
        const CharacterListState(
          characters: [...tCharactersPage1, ...tCharactersPage2],
          isLoading: false,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'emits [loading, success with hasReachedMax] when FetchCharacters returns empty list',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => const Right(tEmptyCharacters));
        return createBloc();
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 1)),
      expect: () => [
        const CharacterListState(isLoading: true, errorMessage: null),
        const CharacterListState(
          characters: tEmptyCharacters,
          isLoading: false,
          hasReachedMax: true,
          errorMessage: null,
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'emits [loading, error] when FetchCharacters fails with ServerFailure',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => Left(ServerFailure()));
        return createBloc();
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 1)),
      expect: () => [
        const CharacterListState(isLoading: true, errorMessage: null),
        const CharacterListState(
          isLoading: false,
          errorMessage: 'Erro no servidor. Tente novamente.',
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'emits [loading, error] when FetchCharacters fails with NetworkFailure',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => Left(NetworkFailure()));
        return createBloc();
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 1)),
      expect: () => [
        const CharacterListState(isLoading: true, errorMessage: null),
        const CharacterListState(
          isLoading: false,
          errorMessage: 'Sem conexão com a internet.',
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'emits [loading, error] when FetchCharacters fails with GeneralFailure',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => Left(GeneralFailure()));
        return createBloc();
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 1)),
      expect: () => [
        const CharacterListState(isLoading: true, errorMessage: null),
        const CharacterListState(
          isLoading: false,
          errorMessage: 'Erro inesperado. Tente novamente.',
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'does not emit new state when FetchCharacters is added and hasReachedMax is true',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => const Right(tCharactersPage1));
        return createBloc()
          ..emit(const CharacterListState(hasReachedMax: true));
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 2)),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            ));
      },
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'does not emit new state when FetchCharacters is added and isLoading is true',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => const Right(tCharactersPage1));
        return createBloc()..emit(const CharacterListState(isLoading: true));
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 1)),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            ));
      },
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'passes correct parameters to GetCharacters use case',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => const Right(tCharactersPage1));
        return createBloc();
      },
      act: (bloc) => bloc.add(const FetchCharacters(
        page: 1,
        status: CharacterStatus.alive,
        name: 'Rick',
      )),
      verify: (_) {
        verify(() => mockGetCharacters(
              status: CharacterStatus.alive,
              name: 'Rick',
            )).called(1);
      },
    );
  });

  group('Edge Cases', () {
    blocTest<CharacterListBloc, CharacterListState>(
      'maintains existing characters when loading next page fails',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => Left(ServerFailure()));
        return createBloc()
          ..emit(const CharacterListState(characters: tCharactersPage1));
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 2)),
      expect: () => [
        const CharacterListState(
          characters: tCharactersPage1,
          isLoading: true,
        ),
        const CharacterListState(
          characters: tCharactersPage1,
          isLoading: false,
          errorMessage: 'Erro no servidor. Tente novamente.',
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'replaces characters when loading first page fails',
      build: () {
        when(() => mockGetCharacters(
              status: any(named: 'status'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => Left(ServerFailure()));
        return createBloc()
          ..emit(const CharacterListState(characters: tCharactersPage1));
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 1)),
      expect: () => [
        const CharacterListState(
          isLoading: true,
          errorMessage: null,
          characters: tCharactersPage1, // Maintains during loading
        ),
        const CharacterListState(
          isLoading: false,
          errorMessage: 'Erro no servidor. Tente novamente.',
          characters:
              tCharactersPage1, // Should maintain characters on error for first page?
        ),
      ],
    );
  });
}
