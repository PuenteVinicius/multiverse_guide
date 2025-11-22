import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiverse_guide/presentation/pages/characters_list/characters_list_page_test.dart'
    as app;

void main() {
  var IntegrationTestWidgetsFlutterBinding;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Character Flow Integration Test', () {
    testWidgets('Complete character list and detail flow',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app starts with loading
      expect(find.text('Carregando personagens...'), findsOneWidget);

      // Wait for characters to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify characters are displayed
      expect(find.text('Rick Sanchez'), findsWidgets);

      // Tap on first character
      await tester.tap(find.text('Rick Sanchez').first);
      await tester.pumpAndSettle();

      // Verify detail page is displayed
      expect(find.text('Informações do Personagem'), findsOneWidget);
      expect(find.text('Detalhes'), findsOneWidget);
      expect(find.text('Localizações'), findsOneWidget);
      expect(find.text('Participação'), findsOneWidget);

      // Go back to list
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we're back to list
      expect(find.text('Guia do Multiverso'), findsOneWidget);
    });

    testWidgets('Search functionality', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Enter search text
      await tester.enterText(
        find.byType(TextField),
        'Rick',
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify search results
      expect(find.text('Rick Sanchez'), findsWidgets);
    });
  });
}
