import 'dart:async';
import 'package:flutter/material.dart';

/// Repräsentiert einen Schnappschuss von Text und Cursor-Position.
class TextHistorySnapshot {
  final String text;
  final TextSelection selection;

  const TextHistorySnapshot(this.text, this.selection);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextHistorySnapshot &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          selection == other.selection;

  @override
  int get hashCode => Object.hash(text, selection);

  @override
  String toString() => 'TextHistorySnapshot(textLength: ${text.length}, selection: $selection)';
}

/// Verwaltet Undo (Rückgängig) und Redo (Wiederholen) für einen [TextEditingController].
///
/// Unterstützt:
/// - Gruppiertes Tippen (Debounce)
/// - Programmatische Checkpoints für Snippets (Fett, Kursiv, Tabellen, Bilder)
/// - Tastatur-Shortcuts (Ctrl+Z / Ctrl+Y)
/// - Begrenzte Historienlänge zur Speicheroptimierung
class EditorHistoryManager {
  final TextEditingController controller;
  final int maxHistoryLength;
  final Duration debounceDuration;
  final VoidCallback? onHistoryChanged;

  final List<TextHistorySnapshot> _undoStack = [];
  final List<TextHistorySnapshot> _redoStack = [];

  late TextHistorySnapshot _lastCommittedSnapshot;
  Timer? _debounceTimer;
  bool _isApplyingSnapshot = false;

  EditorHistoryManager({
    required this.controller,
    this.maxHistoryLength = 60,
    this.debounceDuration = const Duration(milliseconds: 600),
    this.onHistoryChanged,
  }) {
    _lastCommittedSnapshot = TextHistorySnapshot(
      controller.text,
      controller.selection,
    );
    controller.addListener(_onTextChanged);
  }

  /// Gibt an, ob ein Rückgängig-Schritt verfügbar ist.
  bool get canUndo {
    final currentText = controller.text;
    return _undoStack.isNotEmpty || currentText != _lastCommittedSnapshot.text;
  }

  /// Gibt an, ob ein Wiederholen-Schritt verfügbar ist.
  bool get canRedo => _redoStack.isNotEmpty;

  int get undoCount => _undoStack.length + (controller.text != _lastCommittedSnapshot.text ? 1 : 0);
  int get redoCount => _redoStack.length;

  /// Rückgängig machen der letzten Textänderung.
  bool undo() {
    if (!canUndo) return false;

    _debounceTimer?.cancel();
    _debounceTimer = null;

    final current = TextHistorySnapshot(controller.text, controller.selection);

    // Falls aktuell getippter Text noch nicht als Checkpoint committet wurde:
    if (current.text != _lastCommittedSnapshot.text) {
      _redoStack.add(current);
      _applySnapshot(_lastCommittedSnapshot);
      onHistoryChanged?.call();
      return true;
    }

    if (_undoStack.isNotEmpty) {
      _redoStack.add(current);
      final previous = _undoStack.removeLast();
      _lastCommittedSnapshot = previous;
      _applySnapshot(previous);
      onHistoryChanged?.call();
      return true;
    }

    return false;
  }

  /// Wiederherstellen der zuletzt rückgängig gemachten Textänderung.
  bool redo() {
    if (!canRedo) return false;

    _debounceTimer?.cancel();
    _debounceTimer = null;

    final current = TextHistorySnapshot(controller.text, controller.selection);
    final next = _redoStack.removeLast();

    _undoStack.add(current);
    if (_undoStack.length > maxHistoryLength) {
      _undoStack.removeAt(0);
    }

    _lastCommittedSnapshot = next;
    _applySnapshot(next);
    onHistoryChanged?.call();
    return true;
  }

  /// Vor einer programmatischen Änderung aufrufen (z. B. Markdown-Snippet einfügen).
  void recordBeforeProgrammaticChange() {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    final current = TextHistorySnapshot(controller.text, controller.selection);

    // Falls aktuell uncommitteter getippter Text vorhanden ist, Vorzustand festhalten
    if (current.text != _lastCommittedSnapshot.text) {
      _undoStack.add(_lastCommittedSnapshot);
    }

    if (_undoStack.isEmpty || _undoStack.last.text != current.text) {
      _undoStack.add(current);
      if (_undoStack.length > maxHistoryLength) {
        _undoStack.removeAt(0);
      }
    }

    _redoStack.clear();
    _lastCommittedSnapshot = current;
    onHistoryChanged?.call();
  }

  /// Nach der programmatischen Änderung aufrufen, um den neuen Zustand zu sichern.
  void recordAfterProgrammaticChange() {
    _lastCommittedSnapshot = TextHistorySnapshot(controller.text, controller.selection);
    onHistoryChanged?.call();
  }

  /// Setzt die Historie komplett zurück (z. B. beim Laden einer neuen Datei).
  void clearHistory() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _undoStack.clear();
    _redoStack.clear();
    _lastCommittedSnapshot = TextHistorySnapshot(controller.text, controller.selection);
    onHistoryChanged?.call();
  }

  void _onTextChanged() {
    if (_isApplyingSnapshot) return;

    final currentText = controller.text;
    if (currentText == _lastCommittedSnapshot.text) {
      // Nur Selektions- / Cursorbewegung, kein Textinhalt verändert
      return;
    }

    // Sobald getippt wird, verfällt der Redo-Stack
    if (_redoStack.isNotEmpty) {
      _redoStack.clear();
    }

    onHistoryChanged?.call();

    // Debounce für aufeinanderfolgende Tastatureingaben
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, _commitTypingSnapshot);
  }

  void _commitTypingSnapshot() {
    final current = TextHistorySnapshot(controller.text, controller.selection);
    if (current.text != _lastCommittedSnapshot.text) {
      _undoStack.add(_lastCommittedSnapshot);
      if (_undoStack.length > maxHistoryLength) {
        _undoStack.removeAt(0);
      }
      _lastCommittedSnapshot = current;
      onHistoryChanged?.call();
    }
  }

  void _applySnapshot(TextHistorySnapshot snapshot) {
    _isApplyingSnapshot = true;
    try {
      // Sichere Auswahlgrenzen innerhalb der Textlänge
      final safeStart = snapshot.selection.start.clamp(0, snapshot.text.length);
      final safeEnd = snapshot.selection.end.clamp(0, snapshot.text.length);

      controller.value = TextEditingValue(
        text: snapshot.text,
        selection: TextSelection(baseOffset: safeStart, extentOffset: safeEnd),
      );
    } finally {
      _isApplyingSnapshot = false;
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    controller.removeListener(_onTextChanged);
  }
}
