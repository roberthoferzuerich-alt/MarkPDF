import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_writer/models/app_state.dart';
import 'package:pdf_writer/models/editor_history_manager.dart';
import 'package:pdf_writer/widgets/editor_toolbar.dart';

void main() {
  group('EditorHistoryManager Unit Tests', () {
    late TextEditingController controller;
    late EditorHistoryManager history;
    int changeNotifications = 0;

    setUp(() {
      controller = TextEditingController(text: 'Start');
      changeNotifications = 0;
      history = EditorHistoryManager(
        controller: controller,
        debounceDuration: const Duration(milliseconds: 50),
        onHistoryChanged: () => changeNotifications++,
      );
    });

    tearDown(() {
      history.dispose();
      controller.dispose();
    });

    test('Initial state cannot undo or redo', () {
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isFalse);
      expect(history.undo(), isFalse);
      expect(history.redo(), isFalse);
    });

    test('Typing allows immediate undo and restores original text', () {
      controller.text = 'Start and More';
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);

      final undone = history.undo();
      expect(undone, isTrue);
      expect(controller.text, equals('Start'));
      expect(history.canRedo, isTrue);

      final redone = history.redo();
      expect(redone, isTrue);
      expect(controller.text, equals('Start and More'));
    });

    test('Multiple debounced typing steps can be undone sequentially', () async {
      controller.text = 'Step 1';
      await Future<void>.delayed(const Duration(milliseconds: 70));

      controller.text = 'Step 2';
      await Future<void>.delayed(const Duration(milliseconds: 70));

      controller.text = 'Step 3';

      expect(controller.text, equals('Step 3'));

      // Undo Step 3 -> Step 2
      expect(history.undo(), isTrue);
      expect(controller.text, equals('Step 2'));

      // Undo Step 2 -> Step 1
      expect(history.undo(), isTrue);
      expect(controller.text, equals('Step 1'));

      // Undo Step 1 -> Start
      expect(history.undo(), isTrue);
      expect(controller.text, equals('Start'));

      expect(history.canUndo, isFalse);

      // Redo back to Step 1
      expect(history.redo(), isTrue);
      expect(controller.text, equals('Step 1'));

      // Redo back to Step 2
      expect(history.redo(), isTrue);
      expect(controller.text, equals('Step 2'));

      // Redo back to Step 3
      expect(history.redo(), isTrue);
      expect(controller.text, equals('Step 3'));
    });

    test('Programmatic checkpoints record immediately and are undoable in one step', () {
      history.recordBeforeProgrammaticChange();
      controller.text = '# Heading 1\nStart';
      history.recordAfterProgrammaticChange();

      expect(history.canUndo, isTrue);
      expect(controller.text, equals('# Heading 1\nStart'));

      // Undoing reverts directly to Start
      expect(history.undo(), isTrue);
      expect(controller.text, equals('Start'));

      // Redoing restores Heading
      expect(history.redo(), isTrue);
      expect(controller.text, equals('# Heading 1\nStart'));
    });

    test('Typing after undo clears redo stack', () {
      controller.text = 'Changed';
      history.undo();
      expect(history.canRedo, isTrue);

      // New edit clears redo
      controller.text = 'Brand New';
      expect(history.canRedo, isFalse);
    });

    testWidgets('EditorToolbar undo and redo buttons update and revert programmatic snippets', (tester) async {
      final appState = AppState();
      addTearDown(appState.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorToolbar(appState: appState),
          ),
        ),
      );

      final initialText = appState.markdownContent;

      // Tap bold button
      final boldButton = find.byTooltip('Fett (Bold)');
      expect(boldButton, findsOneWidget);
      await tester.tap(boldButton);
      await tester.pump();

      expect(appState.markdownContent, contains('**Fetter Text**'));
      expect(appState.canUndo, isTrue);

      // Tap Undo button
      final undoButton = find.byTooltip('Rückgängig (Strg+Z)');
      expect(undoButton, findsOneWidget);
      await tester.tap(undoButton);
      await tester.pump();

      expect(appState.markdownContent, equals(initialText));
      expect(appState.canRedo, isTrue);

      // Tap Redo button
      final redoButton = find.byTooltip('Wiederholen (Strg+Y)');
      expect(redoButton, findsOneWidget);
      await tester.tap(redoButton);
      await tester.pump();

      expect(appState.markdownContent, contains('**Fetter Text**'));
    });
  });
}
