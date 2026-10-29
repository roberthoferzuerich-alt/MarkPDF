import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:printing/printing.dart';
import '../models/app_state.dart';
import '../models/document_statistics.dart';
import '../services/file_service.dart';
import '../services/markdown_to_pdf_service.dart';
import '../widgets/document_statistics_sheet.dart';
import '../widgets/editor_toolbar.dart';
import 'help_screen.dart';

enum EditorViewMode {
  split,
  editorOnly,
  previewOnly,
}

class MarkdownEditorScreen extends StatefulWidget {
  final AppState appState;

  const MarkdownEditorScreen({super.key, required this.appState});

  @override
  State<MarkdownEditorScreen> createState() => _MarkdownEditorScreenState();
}

class _MarkdownEditorScreenState extends State<MarkdownEditorScreen> {
  EditorViewMode _viewMode = EditorViewMode.split;

  Future<void> _loadFile() async {
    final loaded = await widget.appState.loadMarkdownFromFile();
    if (loaded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Markdown-Datei erfolgreich geladen!')),
      );
    }
  }

  Future<void> _saveFile() async {
    final path = await FileService.saveMarkdownFile(widget.appState.markdownContent);
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gespeichert unter: $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speichern abgebrochen oder auf dieser Plattform nicht verfügbar.')),
        );
      }
    }
  }

  Future<void> _printMarkdown() async {
    if (widget.appState.markdownContent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein Text zum Drucken vorhanden.')),
      );
      return;
    }
    try {
      await Printing.layoutPdf(
        name: 'MarkPDF Dokument',
        onLayout: (format) => MarkdownToPdfService.generatePdfBytes(
          widget.appState.markdownContent,
          title: 'MarkPDF Ausdruck',
          pageFormat: format,
          themeType: widget.appState.selectedPdfTheme,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Starten des Druckauftrags: $e')),
        );
      }
    }
  }

  void _showStatistics() {
    final stats = DocumentStatistics.fromText(widget.appState.markdownContent);
    DocumentStatisticsSheet.show(context, stats);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopOrTablet = MediaQuery.sizeOf(context).width >= 800;

    // Auf kleinen Bildschirmen automatisch auf Einzelseiten umschalten, wenn 'split' noch aktiv ist
    final effectiveMode = !isDesktopOrTablet && _viewMode == EditorViewMode.split
        ? EditorViewMode.editorOnly
        : _viewMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Markdown Studio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Ansichtsmodus Umschalter
          if (isDesktopOrTablet)
            SegmentedButton<EditorViewMode>(
              segments: const [
                ButtonSegment(
                  value: EditorViewMode.editorOnly,
                  icon: Icon(Icons.edit, size: 16),
                  tooltip: 'Nur Editor',
                ),
                ButtonSegment(
                  value: EditorViewMode.split,
                  icon: Icon(Icons.vertical_split, size: 16),
                  tooltip: 'Geteilte Ansicht',
                ),
                ButtonSegment(
                  value: EditorViewMode.previewOnly,
                  icon: Icon(Icons.visibility, size: 16),
                  tooltip: 'Nur Vorschau',
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (newSelection) {
                setState(() => _viewMode = newSelection.first);
              },
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            )
          else
            // Auf Smartphones: Kompakter Toggle-Button spart ca. 140px Platz in der AppBar!
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                effectiveMode == EditorViewMode.previewOnly
                    ? Icons.edit
                    : Icons.visibility,
              ),
              tooltip: effectiveMode == EditorViewMode.previewOnly
                  ? 'Zum Editor wechseln'
                  : 'Zur Vorschau wechseln',
              onPressed: () {
                setState(() {
                  _viewMode = effectiveMode == EditorViewMode.previewOnly
                      ? EditorViewMode.editorOnly
                      : EditorViewMode.previewOnly;
                });
              },
            ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Dokument-Statistiken',
            onPressed: _showStatistics,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Direkt drucken',
            onPressed: _printMarkdown,
          ),
          const SizedBox(width: 4),

          PopupMenuButton<String>(
            tooltip: 'Datei-Aktionen',
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'undo':
                  if (widget.appState.canUndo) widget.appState.undo();
                  break;
                case 'redo':
                  if (widget.appState.canRedo) widget.appState.redo();
                  break;
                case 'stats':
                  _showStatistics();
                  break;
                case 'print':
                  _printMarkdown();
                  break;
                case 'open':
                  _loadFile();
                  break;
                case 'save':
                  _saveFile();
                  break;
                case 'reset':
                  widget.appState.resetToSample();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Beispiel-Markdown wiederhergestellt.')),
                  );
                  break;
                case 'clear':
                  widget.appState.updateMarkdown('');
                  break;
                case 'settings':
                  widget.appState.setTabIndex(3);
                  break;
                case 'help':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'undo',
                enabled: widget.appState.canUndo,
                child: const Row(
                  children: [
                    Icon(Icons.undo, size: 20),
                    SizedBox(width: 10),
                    Text('Rückgängig (Strg+Z)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'redo',
                enabled: widget.appState.canRedo,
                child: const Row(
                  children: [
                    Icon(Icons.redo, size: 20),
                    SizedBox(width: 10),
                    Text('Wiederholen (Strg+Y)'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 20, color: Colors.indigo),
                    SizedBox(width: 10),
                    Text('Dokument-Statistiken'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print_outlined, size: 20, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Markdown drucken'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.file_open_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('.md Datei laden'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Als .md speichern'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore, size: 20),
                    SizedBox(width: 10),
                    Text('Muster-Vorlage laden'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Editor leeren', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20, color: Colors.teal),
                    SizedBox(width: 10),
                    Text('Einstellungen'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline, size: 20, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Hilfe & Handbuch'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          if (isDesktopOrTablet)
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('Zu PDF'),
              onPressed: () => widget.appState.setTabIndex(2),
            )
          else
            IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.picture_as_pdf, size: 20),
              tooltip: 'Zu PDF wechseln',
              onPressed: () => widget.appState.setTabIndex(2),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Formatierungs-Toolbar
          EditorToolbar(appState: widget.appState),

          // Editor & Live Vorschau Bereich
          Expanded(
            child: _buildContentArea(effectiveMode, theme),
          ),

          // Dokument-Statistikleiste
          _buildDocumentStatusBar(theme),
        ],
      ),
    );
  }

  Widget _buildDocumentStatusBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final stats = DocumentStatistics.fromText(widget.appState.markdownContent);

        return InkWell(
          onTap: _showStatistics,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.notes, size: 14, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${stats.words} Wörter · ${stats.charactersWithSpaces} Zeichen · ~${stats.readingTimeMinutes} Min. Lesezeit · ${stats.lines} Zeilen',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Details',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 14, color: colorScheme.primary),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentArea(EditorViewMode mode, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    switch (mode) {
      case EditorViewMode.editorOnly:
        return _buildEditorPane(theme);

      case EditorViewMode.previewOnly:
        return _buildPreviewPane(theme);

      case EditorViewMode.split:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: _buildEditorPane(theme),
            ),
            Container(width: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            Expanded(
              flex: 1,
              child: _buildPreviewPane(theme),
            ),
          ],
        );
    }
  }

  Widget _buildEditorPane(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final gradient = widget.appState.editorBackgroundStyle.gradient(isDark);
    final fallbackColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
          if (widget.appState.canUndo) widget.appState.undo();
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () {
          if (widget.appState.canUndo) widget.appState.undo();
        },
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
          if (widget.appState.canRedo) widget.appState.redo();
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true): () {
          if (widget.appState.canRedo) widget.appState.redo();
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true): () {
          if (widget.appState.canRedo) widget.appState.redo();
        },
      },
      child: Container(
        decoration: BoxDecoration(
          color: gradient == null ? fallbackColor : null,
          gradient: gradient,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: widget.appState.markdownController,
          maxLines: null,
          expands: true,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: widget.appState.editorFontSize,
            height: 1.5,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            filled: false,
            fillColor: Colors.transparent,
            hintText: 'Hier Markdown verfassen (# Überschrift, **fett**, Tabellen, Code...)...',
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewPane(ThemeData theme) {
    final content = widget.appState.markdownContent;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header für die Vorschau-Spalte
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Live-Vorschau',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: content.trim().isEmpty
                ? Center(
                    child: Text(
                      'Noch kein Markdown vorhanden.\nTippe links Text ein, um die Live-Vorschau zu sehen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                    ),
                  )
                : Markdown(
                    data: content,
                    selectable: true,
                    padding: const EdgeInsets.all(20),
                    sizedImageBuilder: (config) {
                      final uri = config.uri;
                      final alt = config.alt;
                      final urlString = uri.toString();
                      Widget imageWidget;
                      if (urlString.startsWith('http://') || urlString.startsWith('https://')) {
                        imageWidget = Image.network(
                          urlString,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => _buildImageError(alt),
                        );
                      } else {
                        final filePath = uri.scheme == 'file' ? uri.toFilePath() : urlString;
                        final file = File(filePath);
                        imageWidget = file.existsSync()
                            ? Image.file(file, fit: BoxFit.contain)
                            : _buildImageError(alt);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 280),
                                child: imageWidget,
                              ),
                            ),
                            if (alt != null && alt.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  alt,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      h1: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
                      ),
                      h2: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                      ),
                      h3: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                      p: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      ),
                      code: TextStyle(
                        backgroundColor: isDark ? const Color(0xFF334155) : Colors.pink.shade50,
                        color: isDark ? const Color(0xFFF472B6) : Colors.pink.shade700,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: isDark ? const Color(0xFF020617) : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(4),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF2563EB), width: 4),
                        ),
                      ),
                      tableBorder: TableBorder.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        width: 1,
                      ),
                      tableHead: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                      ),
                      tableBody: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError(String? alt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 18, color: Colors.red.shade400),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              alt != null && alt.isNotEmpty ? 'Bild nicht ladbar: $alt' : 'Bild konnte nicht geladen werden',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
