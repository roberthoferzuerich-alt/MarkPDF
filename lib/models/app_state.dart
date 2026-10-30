import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/editor_background_style.dart';
import '../models/editor_history_manager.dart';
import '../models/pdf_theme_config.dart';
import '../services/file_service.dart';
import '../widgets/sample_markdown.dart';

class AppState extends ChangeNotifier {
  // Navigation
  int _currentTabIndex = 1; // Startet standardmäßig im Markdown-Editor
  int get currentTabIndex => _currentTabIndex;

  // Markdown State & History (Undo / Redo)
  late final TextEditingController markdownController;
  late final EditorHistoryManager historyManager;

  String get markdownContent => markdownController.text;
  bool get canUndo => historyManager.canUndo;
  bool get canRedo => historyManager.canRedo;

  bool undo() => historyManager.undo();
  bool redo() => historyManager.redo();

  // PDF Reader State
  String? _readerPdfPath;
  Uint8List? _readerPdfBytes;
  String _readerPdfTitle = 'Keine Datei geladen';

  String? get readerPdfPath => _readerPdfPath;
  Uint8List? get readerPdfBytes => _readerPdfBytes;
  String get readerPdfTitle => _readerPdfTitle;
  bool get hasReaderPdf => _readerPdfPath != null || _readerPdfBytes != null;

  // Letzte generierte PDF-Bytes
  Uint8List? _lastGeneratedPdfBytes;
  Uint8List? get lastGeneratedPdfBytes => _lastGeneratedPdfBytes;

  // Theme Mode (Dark Mode / Hell / System)
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  // Editor-Einstellungen
  static const double defaultEditorFontSize = 14.0;
  double _editorFontSize = defaultEditorFontSize;
  double get editorFontSize => _editorFontSize;

  void setEditorFontSize(double size) {
    if (_editorFontSize != size) {
      _editorFontSize = size;
      notifyListeners();
    }
  }

  // Editor Hintergrund-Farbverlauf
  EditorBackgroundStyle _editorBackgroundStyle = EditorBackgroundStyle.subtleBlue;
  EditorBackgroundStyle get editorBackgroundStyle => _editorBackgroundStyle;

  void setEditorBackgroundStyle(EditorBackgroundStyle style) {
    if (_editorBackgroundStyle != style) {
      _editorBackgroundStyle = style;
      notifyListeners();
    }
  }

  // PDF Design Theme
  PdfThemeType _selectedPdfTheme = PdfThemeType.modernBusiness;
  PdfThemeType get selectedPdfTheme => _selectedPdfTheme;

  void setPdfTheme(PdfThemeType theme) {
    if (_selectedPdfTheme != theme) {
      _selectedPdfTheme = theme;
      notifyListeners();
    }
  }

  AppState() {
    markdownController = TextEditingController(text: SampleMarkdown.initialDocument);
    historyManager = EditorHistoryManager(
      controller: markdownController,
      onHistoryChanged: notifyListeners,
    );
    markdownController.addListener(() {
      notifyListeners();
    });
  }

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  void updateMarkdown(String newText) {
    if (markdownController.text != newText) {
      historyManager.recordBeforeProgrammaticChange();
      markdownController.text = newText;
      historyManager.recordAfterProgrammaticChange();
      notifyListeners();
    }
  }

  void resetToSample() {
    historyManager.recordBeforeProgrammaticChange();
    markdownController.text = SampleMarkdown.initialDocument;
    historyManager.recordAfterProgrammaticChange();
    notifyListeners();
  }

  void setLastGeneratedPdf(Uint8List bytes) {
    _lastGeneratedPdfBytes = bytes;
  }

  /// Öffnet eine lokale PDF-Datei über den Dateimanager.
  Future<bool> pickAndOpenPdf() async {
    final file = await FileService.pickPdfFile();
    if (file != null) {
      _readerPdfPath = file.path;
      _readerPdfBytes = file.bytes;
      _readerPdfTitle = file.name;
      _currentTabIndex = 0; // Direkt zum Reader-Tab springen
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Lädt das frisch konvertierte PDF direkt in den PDF-Reader-Screen.
  void openGeneratedInReader(Uint8List bytes, {String title = 'Generiertes Dokument.pdf'}) {
    _readerPdfBytes = bytes;
    _readerPdfPath = null;
    _readerPdfTitle = title;
    _lastGeneratedPdfBytes = bytes;
    _currentTabIndex = 0; // Zum Reader wechseln
    notifyListeners();
  }

  /// Lädt eine Markdown-Datei von der Festplatte.
  Future<bool> loadMarkdownFromFile() async {
    final content = await FileService.pickMarkdownFile();
    if (content != null) {
      markdownController.text = content;
      historyManager.clearHistory();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Fügt Markdown-Code an der Cursorposition oder um die Selektion ein.
  void insertMarkdownSnippet(String prefix, {String suffix = '', String defaultText = ''}) {
    historyManager.recordBeforeProgrammaticChange();

    final text = markdownController.text;
    final selection = markdownController.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }

    final selectedText = text.substring(start, end);
    final replacement = selectedText.isEmpty ? defaultText : selectedText;
    final newText = text.replaceRange(start, end, '$prefix$replacement$suffix');

    final newCursorPos = start + prefix.length + replacement.length + (selectedText.isEmpty && defaultText.isEmpty ? 0 : suffix.length);

    markdownController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
    historyManager.recordAfterProgrammaticChange();
    notifyListeners();
  }

  @override
  void dispose() {
    historyManager.dispose();
    markdownController.dispose();
    super.dispose();
  }
}
