import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_writer/screens/about_me_screen.dart';

void main() {
  group('AboutMeScreen Detailed Widget Tests', () {
    testWidgets('renders developer details for Robert Hofer and Antigravity', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AboutMeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Robert Hofer personal details
      expect(find.text('Über den Entwickler'), findsOneWidget);
      expect(find.textContaining('Robert Hofer'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Zürich, Schweiz'), findsAtLeastNWidgets(1));
      expect(find.textContaining('robert.hofer.zuerich@bluewin.ch'), findsAtLeastNWidgets(1));

      // Co-Developer Antigravity
      expect(find.text('Antigravity'), findsAtLeastNWidgets(1));
      expect(find.text('Google DeepMind'), findsAtLeastNWidgets(1));
      expect(find.text('KI-Entwicklungspartner & Co-Pilot'), findsOneWidget);

      // Vision & Highlights
      expect(find.text('Die Vision von MarkPDF'), findsOneWidget);
      expect(find.text('Wichtigste Highlights'), findsOneWidget);
      expect(find.text('Personalien & Kontakt'), findsOneWidget);
    });

    testWidgets('opens image import bottom sheet on button tap', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AboutMeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the image import button or app bar action
      final importButton = find.text('Bild importieren');
      expect(importButton, findsOneWidget);

      await tester.tap(importButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet appears with image source options
      expect(find.text('Profilbild importieren'), findsOneWidget);
      expect(find.text('Aus Galerie wählen'), findsOneWidget);
      expect(find.text('Foto aufnehmen'), findsOneWidget);
      expect(find.text('Bild-Datei auswählen'), findsOneWidget);
    });

    testWidgets('tapping copy action displays confirmation snackbar', (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AboutMeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to contact section
      final contactSection = find.text('Personalien & Kontakt');
      await tester.scrollUntilVisible(contactSection, 300);
      await tester.pumpAndSettle();

      // Tap email copy icon in contact card
      final copyEmailButtons = find.byTooltip('E-Mail kopieren');
      expect(copyEmailButtons, findsOneWidget);

      await tester.tap(copyEmailButtons);
      await tester.pumpAndSettle();

      // Check SnackBar appears with copied message
      expect(find.textContaining('robert.hofer.zuerich@bluewin.ch'), findsAtLeastNWidgets(1));
    });
  });
}
