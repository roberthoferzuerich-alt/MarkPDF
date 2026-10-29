import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_writer/screens/help_screen.dart';

void main() {
  group('HelpScreen Widget Tests', () {
    testWidgets('HelpScreen renders header, search, categories and guide sections', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: HelpScreen(),
        ),
      );

      expect(find.text('Hilfe & Benutzerhandbuch'), findsOneWidget);
      expect(find.text('MarkPDF Handbuch'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify category chips
      expect(find.text('Alle'), findsOneWidget);
      expect(find.text('Schnellstart'), findsOneWidget);
      expect(find.text('Tabellen'), findsOneWidget);
      expect(find.text('Bilder'), findsOneWidget);
      expect(find.text('Shortcuts'), findsOneWidget);

      // Verify section titles
      expect(find.text('1. Schnelleinstieg in 3 Schritten'), findsOneWidget);
      expect(find.text('2. Markdown Textformatierung'), findsOneWidget);
    });

    testWidgets('HelpScreen filters by category chip', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: HelpScreen(),
        ),
      );

      // Tap on "Tabellen" category chip
      final tabellenChip = find.text('Tabellen');
      expect(tabellenChip, findsOneWidget);
      await tester.tap(tabellenChip);
      await tester.pumpAndSettle();

      // Only table section should be shown
      expect(find.text('3. Interaktiver Tabellen-Assistent'), findsOneWidget);
      expect(find.text('1. Schnelleinstieg in 3 Schritten'), findsNothing);
    });

    testWidgets('HelpScreen search finds matching topics and handles empty state', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: HelpScreen(),
        ),
      );

      // Search for "Datenschutz"
      await tester.enterText(find.byType(TextField), 'Datenschutz');
      await tester.pumpAndSettle();

      expect(find.text('9. Häufige Fragen & Datenschutz (FAQ)'), findsOneWidget);
      expect(find.text('1. Schnelleinstieg in 3 Schritten'), findsNothing);

      // Search for nonexistent term
      await tester.enterText(find.byType(TextField), 'xyznonexistent123');
      await tester.pumpAndSettle();

      expect(find.text('Keine passenden Themen gefunden'), findsOneWidget);

      // Reset search via reset button
      final resetButton = find.text('Filter zurücksetzen');
      expect(resetButton, findsOneWidget);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      expect(find.text('1. Schnelleinstieg in 3 Schritten'), findsOneWidget);
    });

    testWidgets('HelpScreen renders cleanly without overflow on 360x740 narrow mobile device', (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: HelpScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HelpScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
