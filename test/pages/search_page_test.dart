import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteroh/pages/search_page.dart';

void main() {
  group('SearchPage Widget Tests', () {
    testWidgets('displays search UI elements', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchPage(),
        ),
      );

      // Assert
      expect(find.text('CityWeather'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Rechercher'), findsOneWidget);
    });

    testWidgets('shows empty state initially', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchPage(),
        ),
      );

      // Assert
      expect(find.text('Recherchez une ville'), findsOneWidget);
      expect(find.text('ou utilisez votre position actuelle'), findsOneWidget);
    });

    testWidgets('text field accepts input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchPage(),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Paris');
      await tester.pump();

      // Assert
      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('search button is tappable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: SearchPage(),
        ),
      );

      // Act
      await tester.tap(find.text('Rechercher'));
      await tester.pump();

      // Assert - should not crash
      expect(find.text('Rechercher'), findsOneWidget);
    });
  });
}
