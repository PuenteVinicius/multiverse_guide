import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiverse_guide/domain/entities/character.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_bloc.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_event.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_state.dart';
import 'package:multiverse_guide/presentation/pages/characters_list/characters_list_page.dart';

class MockCharacterListBloc extends Mock implements CharacterListBloc {}

void main() {
  late MockCharacterListBloc mockCharacterListBloc;

  setUp(() {
    mockCharacterListBloc = MockCharacterListBloc();
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
      episode: const ['https://rickandmortyapi.com/api/episode/1'],
      created: DateTime(2017, 11, 4),
    ),
  ];

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CharacterListBloc>.value(
        value: mockCharacterListBloc,
        child: const CharactersListView(),
      ),
    );
  }

  group('CharactersListPage', () {
    testWidgets('displays loading indicator when state is loading',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockCharacterListBloc.state).thenReturn(
        const CharacterListState(isLoading: true),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Carregando personagens...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays characters when state has data',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockCharacterListBloc.state).thenReturn(
        CharacterListState(characters: tCharacters),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Rick Sanchez'), findsOneWidget);
      expect(find.text('Morty Smith'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays error message when state has error',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockCharacterListBloc.state).thenReturn(
        const CharacterListState(
          errorMessage: 'Test error message',
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Tentar Novamente'), findsOneWidget);
    });

    testWidgets('calls retry when retry button is pressed',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockCharacterListBloc.state).thenReturn(
        const CharacterListState(
          errorMessage: 'Test error message',
        ),
      );
      when(() => mockCharacterListBloc.add(any())).thenReturn(null);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Tentar Novamente'));
      await tester.pump();

      // Assert
      verify(() => mockCharacterListBloc.add(any(that: isA<FetchCharacters>())))
          .called(1);
    });

    testWidgets('displays search bar', (WidgetTester tester) async {
      // Arrange
      when(() => mockCharacterListBloc.state).thenReturn(
        const CharacterListState(),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.hintText('Buscar personagem...'), findsOneWidget);
    });

    testWidgets('displays status filter chips', (WidgetTester tester) async {
      // Arrange
      when(() => mockCharacterListBloc.state).thenReturn(
        const CharacterListState(),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Vivo'), findsOneWidget);
      expect(find.text('Morto'), findsOneWidget);
      expect(find.text('Desconhecido'), findsOneWidget);
    });
  });
}

extension on CommonFinders {
  hintText(String s) {}
}
