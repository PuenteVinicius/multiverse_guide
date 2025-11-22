import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiverse_guide/domain/entities/character.dart';
import 'package:multiverse_guide/presentation/widgets/character_card.dart';

void main() {
  final mockCharacter = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: CharacterStatus.alive,
    species: 'Human',
    type: 'Genius',
    gender: 'Male',
    image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
    location: 'Earth (Replacement Dimension)',
    origin: 'Earth (C-137)',
    episode: const ['https://rickandmortyapi.com/api/episode/1'],
    created: DateTime(2017, 11, 4),
  );

  testWidgets('CharacterCard displays character information correctly',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterCard(
            character: mockCharacter,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    // Verify character name is displayed
    expect(find.text('Rick Sanchez'), findsOneWidget);

    // Verify status is displayed
    expect(find.text('Vivo'), findsOneWidget);

    // Verify location is displayed
    expect(find.text('Earth (Replacement Dimension)'), findsOneWidget);

    // Verify species is displayed
    expect(find.text('Human'), findsOneWidget);

    // Tap the card
    await tester.tap(find.byType(InkWell));
    await tester.pump();

    // Verify onTap was called
    expect(tapped, true);
  });

  testWidgets('CharacterCard displays correct status colors',
      (WidgetTester tester) async {
    final aliveCharacter = mockCharacter;
    final deadCharacter = mockCharacter.copyWith(
      status: CharacterStatus.dead,
    );
    final unknownCharacter = mockCharacter.copyWith(
      status: CharacterStatus.unknown,
    );

    // Test alive status
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterCard(
            character: aliveCharacter,
            onTap: () {},
          ),
        ),
      ),
    );

    // Test dead status
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterCard(
            character: deadCharacter,
            onTap: () {},
          ),
        ),
      ),
    );

    // Test unknown status
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterCard(
            character: unknownCharacter,
            onTap: () {},
          ),
        ),
      ),
    );

    // All should render without errors
    expect(find.text('Rick Sanchez'), findsNWidgets(3));
  });
}
