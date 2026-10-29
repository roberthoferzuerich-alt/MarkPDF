import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_writer/models/app_state.dart';
import 'package:pdf_writer/models/editor_background_style.dart';
import 'package:pdf_writer/screens/about_me_screen.dart';
import 'package:pdf_writer/screens/settings_screen.dart';

void main() {
  group('SettingsScreen & AboutMeScreen Widget Tests', () {
    testWidgets('SettingsScreen switches theme modes and updates appState', (tester) async {
      final appState = AppState();
      addTearDown(appState.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(appState: appState),
        ),
      );

      expect(find.text('Einstellungen'), findsOneWidget);
      expect(find.text('Farbmodus (Dark Mode)'), findsOneWidget);

      // Initially system
      expect(appState.themeMode, equals(ThemeMode.system));

      // Switch to Dunkel
      final darkButton = find.text('Dunkel');
      expect(darkButton, findsOneWidget);
      await tester.tap(darkButton);
      await tester.pump();

      expect(appState.themeMode, equals(ThemeMode.dark));

      // Switch to Hell
      final lightButton = find.text('Hell');
      expect(lightButton, findsOneWidget);
      await tester.tap(lightButton);
      await tester.pump();

      expect(appState.themeMode, equals(ThemeMode.light));
    });

    testWidgets('SettingsScreen navigates to AboutMeScreen on tap', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final appState = AppState();
      addTearDown(appState.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(appState: appState),
        ),
      );

      final aboutCard = find.text('Über mich & MarkPDF');
      await tester.scrollUntilVisible(aboutCard, 300);
      await tester.pumpAndSettle();

      expect(aboutCard, findsOneWidget);

      await tester.tap(aboutCard);
      await tester.pumpAndSettle();

      // We should now be on the AboutMeScreen
      expect(find.byType(AboutMeScreen), findsOneWidget);
      expect(find.text('Über den Entwickler'), findsOneWidget);
      expect(find.text('Die Vision von MarkPDF'), findsOneWidget);
    });

    testWidgets('SettingsScreen navigates to HelpScreen on tap', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final appState = AppState();
      addTearDown(appState.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(appState: appState),
        ),
      );

      final helpCard = find.text('Hilfe & Benutzerhandbuch');
      await tester.scrollUntilVisible(helpCard, 300);
      await tester.pumpAndSettle();

      expect(helpCard, findsOneWidget);

      await tester.tap(helpCard);
      await tester.pumpAndSettle();

      // We should now be on the HelpScreen
      expect(find.text('MarkPDF Handbuch'), findsOneWidget);
      expect(find.text('1. Schnelleinstieg in 3 Schritten'), findsOneWidget);
    });

    testWidgets('SettingsScreen updates editor background gradient style', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final appState = AppState();
      addTearDown(appState.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(appState: appState),
        ),
      );

      // Default is subtleBlue
      expect(appState.editorBackgroundStyle, equals(EditorBackgroundStyle.subtleBlue));

      // Scroll to "Klassisch" and tap it
      final classicOption = find.text('Klassisch');
      await tester.scrollUntilVisible(classicOption, 200);
      await tester.pumpAndSettle();

      await tester.tap(classicOption);
      await tester.pumpAndSettle();

      expect(appState.editorBackgroundStyle, equals(EditorBackgroundStyle.none));

      // Tap "Ozean & Teal"
      final oceanOption = find.text('Ozean & Teal');
      await tester.tap(oceanOption);
      await tester.pumpAndSettle();

      expect(appState.editorBackgroundStyle, equals(EditorBackgroundStyle.oceanTeal));
    });

    testWidgets('AboutMeScreen renders without overflow on 360x740 mobile screen', (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AboutMeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AboutMeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
