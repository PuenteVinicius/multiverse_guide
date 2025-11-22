import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiverse_guide/domain/entities/character.dart';
import 'package:multiverse_guide/domain/usecases/get_characters.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_bloc.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_event.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_state.dart';

class MockGetCharacters extends Mock implements GetCharacters {}

void main() {
  late MockGetCharacters mockGetCharacters;

  setUp(() {
    mockGetCharacters = MockGetCharacters();
  });

  final tCharacters = [
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
      episode: const ['https://rickandmortyapi.com/api/episode/1'],
      created: DateTime(2017, 11, 4),
    ),
  ];

  group('CharacterListBloc', () {
    blocTest<CharacterListBloc, CharacterListState>(
      'emits [loading, success] when FetchCharacters is added and succeeds',
      build: () {
        when(() => mockGetCharacters(any())).thenAnswer(
          (_) async => const Right(tCharacters),
        );
        return CharacterListBloc(getCharacters: mockGetCharacters);
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 1)),
      expect: () => [
        const CharacterListState(isLoading: true),
        CharacterListState(
          characters: tCharacters,
          hasReachedMax: true,
          isLoading: false,
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'emits [loading, error] when FetchCharacters fails',
      build: () {
        when(() => mockGetCharacters(any())).thenAnswer(
          (_) async => Left(ServerFailure()),
        );
        return CharacterListBloc(getCharacters: mockGetCharacters);
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 1)),
      expect: () => [
        const CharacterListState(isLoading: true),
        const CharacterListState(
          isLoading: false,
          errorMessage: 'Erro no servidor. Tente novamente.',
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'emits correct state when FilterCharacters is added',
      build: () {
        when(() => mockGetCharacters(any())).thenAnswer(
          (_) async => const Right(tCharacters),
        );
        return CharacterListBloc(getCharacters: mockGetCharacters);
      },
      act: (bloc) =>
          bloc.add(const FilterCharacters(status: CharacterStatus.alive)),
      expect: () => [
        const CharacterListState(
          characters: [],
          hasReachedMax: false,
          isLoading: true,
        ),
        const CharacterListState(
          characters: tCharacters,
          hasReachedMax: true,
          isLoading: false,
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'emits correct state when SearchCharacters is added',
      build: () {
        when(() => mockGetCharacters(any())).thenAnswer(
          (_) async => const Right(tCharacters),
        );
        return CharacterListBloc(getCharacters: mockGetCharacters);
      },
      act: (bloc) => bloc.add(const SearchCharacters(name: 'Rick')),
      expect: () => [
        const CharacterListState(
          characters: [],
          hasReachedMax: false,
          isLoading: true,
          searchQuery: 'Rick',
        ),
        CharacterListState(
          characters: tCharacters,
          hasReachedMax: true,
          isLoading: false,
          searchQuery: 'Rick',
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'emits correct state when ClearSearch is added',
      build: () {
        when(() => mockGetCharacters(any())).thenAnswer(
          (_) async => const Right(tCharacters),
        );
        return CharacterListBloc(getCharacters: mockGetCharacters);
      },
      act: (bloc) => bloc.add(const ClearSearch()),
      expect: () => [
        const CharacterListState(
          characters: [],
          hasReachedMax: false,
          isLoading: true,
          searchQuery: null,
        ),
        CharacterListState(
          characters: tCharacters,
          hasReachedMax: true,
          isLoading: false,
          searchQuery: null,
        ),
      ],
    );

    blocTest<CharacterListBloc, CharacterListState>(
      'does not emit new state when FetchCharacters is added and hasReachedMax is true',
      build: () {
        when(() => mockGetCharacters(any())).thenAnswer(
          (_) async => const Right([]),
        );
        return CharacterListBloc(getCharacters: mockGetCharacters)
          ..emit(const CharacterListState(hasReachedMax: true));
      },
      act: (bloc) => bloc.add(const FetchCharacters(page: 2)),
      expect: () => [],
    );

    test('calls GetCharacters with correct parameters', () async {
      // Arrange
      when(() => mockGetCharacters(any())).thenAnswer(
        (_) async => const Right(tCharacters),
      );
      final bloc = CharacterListBloc(getCharacters: mockGetCharacters);

      // Act
      bloc.add(const FetchCharacters(
        page: 2,
        status: CharacterStatus.alive,
        name: 'Rick',
      ));

      // Wait for the event to be processed
      await untilCalled(() => mockGetCharacters(any()));

      // Assert
      verify(() => mockGetCharacters(GetCharactersParams(
            page: 2,
            status: CharacterStatus.alive,
            name: 'Rick',
          ))).called(1);
    });
  });
}
