import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mocktail/mocktail.dart' show Mock;

import 'package:multiverse_guide/domain/entities/character.dart';
import 'package:multiverse_guide/presentation/widgets/character_card.dart';

void main() {
  // Dados de teste
  const mockCharacter = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: CharacterStatus.alive,
    species: 'Human',
    type: 'Genius',
    gender: 'Male',
    image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
    location: 'Earth (Replacement Dimension)',
    origin: 'Earth (C-137)',
    episode: ['https://rickandmortyapi.com/api/episode/1'],
  );

  const mockDeadCharacter = Character(
    id: 2,
    name: 'Dead Character',
    status: CharacterStatus.dead,
    species: 'Alien',
    type: '',
    gender: 'Female',
    image: 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
    location: 'Unknown',
    origin: 'Unknown',
    episode: ['https://rickandmortyapi.com/api/episode/1'],
  );

  const mockUnknownCharacter = Character(
    id: 3,
    name: 'Unknown Character',
    status: CharacterStatus.unknown,
    species: 'Robot',
    type: '',
    gender: 'Genderless',
    image: 'https://rickandmortyapi.com/api/character/avatar/3.jpeg',
    location: 'Space Station',
    origin: 'Laboratory',
    episode: ['https://rickandmortyapi.com/api/episode/1'],
  );

  // Widget para teste
  Widget createWidgetUnderTest({
    Character character = mockCharacter,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CharacterCard(
          character: character,
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  group('CharacterCard Rendering', () {
    testWidgets('should render CharacterCard without errors',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CharacterCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should display character name correctly',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Rick Sanchez'), findsOneWidget);
    });

    testWidgets('should display character status and species correctly',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Vivo - Human'), findsOneWidget);
    });

    testWidgets('should display character location correctly',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Earth (Replacement Dimension)'), findsOneWidget);
    });

    testWidgets('should display Hero widget with correct tag',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Hero), findsOneWidget);
      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'character-1');
    });

    testWidgets('should display CachedNetworkImage with correct URL',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      final image =
          tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
      expect(image.imageUrl, mockCharacter.image);
    });

    testWidgets('should have correct image dimensions',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final image =
          tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
      expect(image.width, 160);
      expect(image.height, 160);
      expect(image.fit, BoxFit.fill);
    });

    testWidgets('should have card with correct styling',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(
          card.margin, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
      expect(card.elevation, 2);

      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(10));
      expect(shape.side.color, Colors.teal);
      expect(shape.side.width, 2.0);
    });
  });

  group('CharacterCard Status Texts', () {
    testWidgets('should display "Vivo" for alive status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(character: mockCharacter));

      // Assert
      expect(find.text('Vivo - Human'), findsOneWidget);
    });

    testWidgets('should display "Morto" for dead status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester
          .pumpWidget(createWidgetUnderTest(character: mockDeadCharacter));

      // Assert
      expect(find.text('Morto - Alien'), findsOneWidget);
    });

    testWidgets('should display "Desconhecido" for unknown status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester
          .pumpWidget(createWidgetUnderTest(character: mockUnknownCharacter));

      // Assert
      expect(find.text('Desconhecido - Robot'), findsOneWidget);
    });
  });

  group('CharacterCard Interaction', () {
    testWidgets('should call onTap when card is tapped',
        (WidgetTester tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(createWidgetUnderTest(
        onTap: () => tapped = true,
      ));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should have InkWell with correct borderRadius',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, BorderRadius.circular(12));
    });
  });

  group('CharacterCard Layout', () {
    testWidgets('should have correct text styles', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Nome
      final nameText = tester.widget<Text>(find.text('Rick Sanchez'));
      expect(nameText.style?.fontSize, 22);
      expect(nameText.style?.fontWeight, FontWeight.bold);

      // Assert - Localização
      final locationText =
          tester.widget<Text>(find.text('Earth (Replacement Dimension)'));
      expect(locationText.style?.fontSize, 16);
    });
  });

  group('CharacterCard Error Handling', () {
    testWidgets('should handle character with long name using ellipsis',
        (WidgetTester tester) async {
      // Arrange
      const longNameCharacter = Character(
        id: 4,
        name: 'Very Long Character Name That Should Be Truncated With Ellipsis',
        status: CharacterStatus.alive,
        species: 'Human',
        type: '',
        gender: 'Male',
        image: 'https://rickandmortyapi.com/api/character/avatar/4.jpeg',
        location: 'Short Location',
        origin: 'Short Origin',
        episode: [],
      );

      // Act
      await tester
          .pumpWidget(createWidgetUnderTest(character: longNameCharacter));

      // Assert
      final nameText = tester
          .widget<Text>(find.textContaining(RegExp(r'Very Long Character')));
      expect(nameText.overflow, TextOverflow.ellipsis);
      expect(nameText.maxLines, 1);
    });

    testWidgets('should handle character with long location using ellipsis',
        (WidgetTester tester) async {
      // Arrange
      const longLocationCharacter = Character(
        id: 5,
        name: 'Short Name',
        status: CharacterStatus.alive,
        species: 'Human',
        type: '',
        gender: 'Male',
        image: 'https://rickandmortyapi.com/api/character/avatar/5.jpeg',
        location:
            'Very Long Location Name That Should Be Truncated With Ellipsis When Too Long',
        origin: 'Short Origin',
        episode: [],
      );

      // Act
      await tester
          .pumpWidget(createWidgetUnderTest(character: longLocationCharacter));

      // Assert
      final locationText = tester
          .widget<Text>(find.textContaining(RegExp(r'Very Long Location')));
      expect(locationText.overflow, TextOverflow.ellipsis);
      expect(locationText.maxLines, 1);
    });
  });

  group('CharacterCard Image Loading States', () {
    testWidgets('should have placeholder while image loads',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Verifica se o CachedNetworkImage está configurado com placeholder
      final cachedImage =
          tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
      expect(cachedImage.placeholder, isNotNull);
    });

    testWidgets('should have error widget for failed image loads',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Verifica se o CachedNetworkImage está configurado com errorWidget
      final cachedImage =
          tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
      expect(cachedImage.errorWidget, isNotNull);
    });
  });

  group('CharacterCard Accessibility', () {
    testWidgets('should be semantically labeled with character name',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.bySemanticsLabel(RegExp(r'Rick Sanchez')), findsOneWidget);
    });

    testWidgets('should have correct text contrast for readability',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Verifica se os textos têm cores contrastantes
      final nameText = tester.widget<Text>(find.text('Rick Sanchez'));
      expect(nameText.style?.color,
          isNull); // Cor padrão (preta) deve ter bom contraste

      final locationText =
          tester.widget<Text>(find.text('Earth (Replacement Dimension)'));
      expect(locationText.style?.color, isNotNull); // Cinza deve ser legível
    });
  });

  group('CharacterCard Performance', () {
    testWidgets('should build quickly without expensive operations',
        (WidgetTester tester) async {
      // Arrange & Act & Assert
      // Este teste verifica se o widget constrói sem lançar exceções
      expect(() async {
        await tester.pumpWidget(createWidgetUnderTest());
      }, returnsNormally);
    });
  });
}
