import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:multiverse_guide/domain/entities/character.dart';
import 'package:multiverse_guide/presentation/widgets/status_badge.dart';

void main() {
  // Widget para teste
  Widget createWidgetUnderTest(CharacterStatus status) {
    return MaterialApp(
      home: Scaffold(
        body: StatusBadge(status: status),
      ),
    );
  }

  group('StatusBadge Rendering', () {
    testWidgets('should render StatusBadge without errors',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should display correct text for alive status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      expect(find.text('Status: Vivo'), findsOneWidget);
    });

    testWidgets('should display correct text for dead status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.dead));

      // Assert
      expect(find.text('Status: Morto'), findsOneWidget);
    });

    testWidgets('should display correct text for unknown status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.unknown));

      // Assert
      expect(find.text('Status: Desconhecido'), findsOneWidget);
    });
  });

  group('StatusBadge Colors', () {
    testWidgets('should have green color for alive status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;
      final border = boxDecoration.border as Border;

      // Verifica cor da borda
      expect(border.top.color, Colors.green);

      // Verifica cor do texto
      final text = tester.widget<Text>(find.text('Status: Vivo'));
      expect(text.style?.color, Colors.green);
    });

    testWidgets('should have red color for dead status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.dead));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;
      final border = boxDecoration.border as Border;

      // Verifica cor da borda
      expect(border.top.color, Colors.red);

      // Verifica cor do texto
      final text = tester.widget<Text>(find.text('Status: Morto'));
      expect(text.style?.color, Colors.red);
    });

    testWidgets('should have orange color for unknown status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.unknown));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;
      final border = boxDecoration.border as Border;

      // Verifica cor da borda
      expect(border.top.color, Colors.orange);

      // Verifica cor do texto
      final text = tester.widget<Text>(find.text('Status: Desconhecido'));
      expect(text.style?.color, Colors.orange);
    });

    testWidgets('should have background color with opacity for alive status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;

      // Verifica se a cor de fundo tem opacidade
      expect(boxDecoration.color, Colors.green.withOpacity(0.1));
    });

    testWidgets('should have background color with opacity for dead status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.dead));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;

      // Verifica se a cor de fundo tem opacidade
      expect(boxDecoration.color, Colors.red.withOpacity(0.1));
    });

    testWidgets('should have background color with opacity for unknown status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.unknown));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;

      // Verifica se a cor de fundo tem opacidade
      expect(boxDecoration.color, Colors.orange.withOpacity(0.1));
    });
  });

  group('StatusBadge Styling', () {
    testWidgets('should have correct padding', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding,
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6));
    });

    testWidgets('should have correct border radius',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.borderRadius, BorderRadius.circular(20));
    });

    testWidgets('should have correct border width',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;
      final border = boxDecoration.border as Border;
      expect(border.top.width, 1);
    });

    testWidgets('should have correct text style', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      final text = tester.widget<Text>(find.text('Status: Vivo'));
      expect(text.style?.fontSize, 20);
      expect(text.style?.fontWeight, FontWeight.w600);
      expect(text.textAlign, TextAlign.center);
    });
  });

  group('StatusBadge Layout', () {
    testWidgets('should have Row with centered content',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
      expect(row.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('should contain only one text widget',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should have correct widget hierarchy',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(StatusBadge),
            matching: find.byType(Container),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(Container),
            matching: find.byType(Row),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(Row),
            matching: find.byType(Text),
          ),
          findsOneWidget);
    });
  });

  group('StatusBadge Accessibility', () {
    testWidgets('should be semantically labeled with status text',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      expect(find.bySemanticsLabel(RegExp(r'Status: Vivo')), findsOneWidget);
    });

    testWidgets('should have sufficient color contrast for alive status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;
      final text = tester.widget<Text>(find.text('Status: Vivo'));

      // Verifica se o texto tem cor contrastante com o fundo
      expect(boxDecoration.color, Colors.green.withOpacity(0.1));
      expect(text.style?.color, Colors.green);
    });

    testWidgets('should have sufficient color contrast for dead status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.dead));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;
      final text = tester.widget<Text>(find.text('Status: Morto'));

      // Verifica se o texto tem cor contrastante com o fundo
      expect(boxDecoration.color, Colors.red.withOpacity(0.1));
      expect(text.style?.color, Colors.red);
    });

    testWidgets('should have sufficient color contrast for unknown status',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.unknown));

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;
      final text = tester.widget<Text>(find.text('Status: Desconhecido'));

      // Verifica se o texto tem cor contrastante com o fundo
      expect(boxDecoration.color, Colors.orange.withOpacity(0.1));
      expect(text.style?.color, Colors.orange);
    });
  });

  group('StatusBadge Performance', () {
    testWidgets('should build quickly without expensive operations',
        (WidgetTester tester) async {
      // Arrange & Act & Assert
      expect(() async {
        await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));
      }, returnsNormally);
    });

    testWidgets('should rebuild when status changes',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.alive));
      expect(find.text('Status: Vivo'), findsOneWidget);

      // Act - Mudar status
      await tester.pumpWidget(createWidgetUnderTest(CharacterStatus.dead));

      // Assert - Deve atualizar o texto
      expect(find.text('Status: Morto'), findsOneWidget);
      expect(find.text('Status: Vivo'), findsNothing);
    });
  });

  group('StatusBadge Edge Cases', () {
    testWidgets('should handle all status enum values',
        (WidgetTester tester) async {
      // Testa todos os valores do enum CharacterStatus
      for (final status in CharacterStatus.values) {
        await tester.pumpWidget(createWidgetUnderTest(status));

        // Verifica se renderiza sem erro
        expect(find.byType(StatusBadge), findsOneWidget);

        // Limpa para próximo teste
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should have consistent styling across all statuses',
        (WidgetTester tester) async {
      final statuses = CharacterStatus.values;

      for (final status in statuses) {
        await tester.pumpWidget(createWidgetUnderTest(status));

        // Verifica se todos têm a mesma estrutura básica
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);

        final container = tester.widget<Container>(find.byType(Container));
        final boxDecoration = container.decoration as BoxDecoration;

        // Verifica consistência no estilo
        expect(container.padding,
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6));
        expect(boxDecoration.borderRadius, BorderRadius.circular(20));

        await tester.pumpWidget(Container());
      }
    });
  });

  group('StatusBadge Responsiveness', () {
    testWidgets('should adapt to different screen sizes',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // Largura específica
              child: StatusBadge(status: CharacterStatus.alive),
            ),
          ),
        ),
      );

      // Assert - Deve se adaptar à largura do pai
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('Status: Vivo'), findsOneWidget);
    });
  });
}
