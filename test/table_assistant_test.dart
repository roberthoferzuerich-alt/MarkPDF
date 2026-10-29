import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_writer/widgets/table_assistant_dialog.dart';

void main() {
  testWidgets('TableAssistantDialog renders and inserts markdown table', (tester) async {
    String? insertedMarkdown;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dContext) => TableAssistantDialog(
                      onInsertTable: (md) {
                        insertedMarkdown = md;
                      },
                    ),
                  );
                },
                child: const Text('Open Table Assistant'),
              );
            },
          ),
        ),
      ),
    );

    // Dialog öffnen
    await tester.tap(find.text('Open Table Assistant'));
    await tester.pumpAndSettle();

    // Dialog Titel vorhanden
    expect(find.text('Tabellen-Assistent'), findsOneWidget);
    expect(find.text('Aufbau & Vorlagen'), findsOneWidget);
    expect(find.text('Inhalte eingeben'), findsOneWidget);

    // Vorlage "Preisliste" wählen
    await tester.tap(find.text('Preisliste'));
    await tester.pumpAndSettle();

    // Auf "Inhalte eingeben" Tab wechseln
    await tester.tap(find.text('Inhalte eingeben'));
    await tester.pumpAndSettle();

    expect(find.text('Inhalte bearbeiten:'), findsOneWidget);

    // Tabelle einfügen Button drücken
    await tester.tap(find.text('Tabelle einfügen'));
    await tester.pumpAndSettle();

    // Prüfen, ob valider Markdown-Code generiert wurde
    expect(insertedMarkdown, isNotNull);
    expect(insertedMarkdown, contains('| Pos. | Bezeichnung | Menge | Einzelpreis | Gesamt |'));
    expect(insertedMarkdown, contains(':---:'));
    expect(insertedMarkdown, contains('MarkPDF Studio Lizenz'));
  });

  testWidgets('TableAssistantDialog has no overflow on narrow mobile screen (360x740)', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dContext) => TableAssistantDialog(
                      onInsertTable: (md) {},
                    ),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Tabellen-Assistent'), findsOneWidget);
    expect(find.text('Größe anpassen'), findsOneWidget);
    expect(find.text('Spalten'), findsOneWidget);
    expect(find.text('Zeilen'), findsOneWidget);
  });
}
