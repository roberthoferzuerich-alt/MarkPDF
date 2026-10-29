import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/app_state.dart';
import '../screens/image_editor_screen.dart';
import '../services/file_service.dart';
import 'table_assistant_dialog.dart';

class EditorToolbar extends StatelessWidget {
  final AppState appState;

  const EditorToolbar({super.key, required this.appState});

  Future<void> _openImageEditor(
    BuildContext context,
    Uint8List bytes, {
    String defaultAlt = 'Foto',
  }) async {
    final result = await Navigator.push<EditedImageResult>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditorScreen(
          imageBytes: bytes,
          initialAlt: defaultAlt,
        ),
      ),
    );

    if (result != null && context.mounted) {
      appState.insertMarkdownSnippet('\n![${result.alt}](${result.path})\n');
      final kb = (result.fileSizeBytes / 1024).toStringAsFixed(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bild (${result.width}x${result.height} px, $kb KB) zugeschnitten & eingefügt!'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showImagePickerModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bild einfügen & anpassen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Colors.blue),
                  title: const Text('Aus Galerie wählen'),
                  subtitle: const Text('Zuschneiden, drehen & auf Webgröße skalieren'),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    try {
                      final path = await FileService.pickImageFromGallery();
                      if (path != null && path.isNotEmpty) {
                        final bytes = await File(path).readAsBytes();
                        if (context.mounted) {
                          await _openImageEditor(context, bytes, defaultAlt: 'Galerie-Foto');
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Galerie-Fehler: $e')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Colors.green),
                  title: const Text('Foto aufnehmen'),
                  subtitle: const Text('Kamerafoto schießen & direkt anpassen'),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    try {
                      final path = await FileService.pickImageFromCamera();
                      if (path != null && path.isNotEmpty) {
                        final bytes = await File(path).readAsBytes();
                        if (context.mounted) {
                          await _openImageEditor(context, bytes, defaultAlt: 'Kamerafoto');
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        final isMissingPlugin = e.toString().contains('MissingPluginException');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isMissingPlugin
                                  ? 'Kamera erfordert einmaligen App-Neustart (flutter run im Terminal neu starten).'
                                  : 'Kamera-Fehler: $e',
                            ),
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.link, color: Colors.purple),
                  title: const Text('Web-Bild (URL)'),
                  subtitle: const Text('Bild-Link aus dem Internet (https://...)'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showUrlInputDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUrlInputDialog(BuildContext context) {
    final urlController = TextEditingController(text: 'https://');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Web-Bild einfügen'),
          content: TextField(
            controller: urlController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Bild-URL',
              hintText: 'https://beispiel.de/bild.png',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            OutlinedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                Navigator.pop(dialogContext);
                if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                  try {
                    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
                    if (response.statusCode == 200 && context.mounted) {
                      await _openImageEditor(context, response.bodyBytes, defaultAlt: 'Web-Bild');
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bild konnte nicht geladen werden (HTTP ${response.statusCode})')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler beim Abrufen des Web-Bildes: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Zuschneiden'),
            ),
            FilledButton(
              onPressed: () {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  appState.insertMarkdownSnippet('\n![Web-Bild]($url)\n');
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Direkt einfügen'),
            ),
          ],
        );
      },
    );
  }

  void _openTableAssistant(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => TableAssistantDialog(
        onInsertTable: (markdown) {
          appState.insertMarkdownSnippet(markdown);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tabelle erfolgreich eingefügt!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: [
              // 1. Historien-Navigation: Vor & Zurück (Undo / Redo)
              _ToolbarIconButton(
                tooltip: appState.canUndo ? 'Rückgängig (Strg+Z)' : 'Rückgängig (keine Änderungen)',
                icon: Icons.undo,
                onTap: appState.canUndo ? appState.undo : null,
              ),
              _ToolbarIconButton(
                tooltip: appState.canRedo ? 'Wiederholen (Strg+Y)' : 'Wiederholen (nichts zum Wiederholen)',
                icon: Icons.redo,
                onTap: appState.canRedo ? appState.redo : null,
              ),
              const _VerticalDivider(),
              _ToolbarButton(
                tooltip: 'Überschrift 1 (H1)',
                label: 'H1',
                onTap: () => appState.insertMarkdownSnippet('\n# ', suffix: '\n', defaultText: 'Überschrift 1'),
              ),
          _ToolbarButton(
            tooltip: 'Überschrift 2 (H2)',
            label: 'H2',
            onTap: () => appState.insertMarkdownSnippet('\n## ', suffix: '\n', defaultText: 'Überschrift 2'),
          ),
          _ToolbarButton(
            tooltip: 'Überschrift 3 (H3)',
            label: 'H3',
            onTap: () => appState.insertMarkdownSnippet('\n### ', suffix: '\n', defaultText: 'Überschrift 3'),
          ),
          const _VerticalDivider(),
          _ToolbarIconButton(
            tooltip: 'Fett (Bold)',
            icon: Icons.format_bold,
            onTap: () => appState.insertMarkdownSnippet('**', suffix: '**', defaultText: 'Fetter Text'),
          ),
          _ToolbarIconButton(
            tooltip: 'Kursiv (Italic)',
            icon: Icons.format_italic,
            onTap: () => appState.insertMarkdownSnippet('*', suffix: '*', defaultText: 'Kursiver Text'),
          ),
          _ToolbarIconButton(
            tooltip: 'Durchgestrichen (Strikethrough)',
            icon: Icons.format_strikethrough,
            onTap: () => appState.insertMarkdownSnippet('~~', suffix: '~~', defaultText: 'Durchgestrichen'),
          ),
          const _VerticalDivider(),
          _ToolbarIconButton(
            tooltip: 'Aufzählung (Bullet List)',
            icon: Icons.format_list_bulleted,
            onTap: () => appState.insertMarkdownSnippet('\n- ', suffix: '\n', defaultText: 'Listeneintrag'),
          ),
          _ToolbarIconButton(
            tooltip: 'Nummerierte Liste (Ordered List)',
            icon: Icons.format_list_numbered,
            onTap: () => appState.insertMarkdownSnippet('\n1. ', suffix: '\n', defaultText: 'Erster Eintrag'),
          ),
          _ToolbarIconButton(
            tooltip: 'Zitat (Blockquote)',
            icon: Icons.format_quote,
            onTap: () => appState.insertMarkdownSnippet('\n> ', suffix: '\n', defaultText: 'Wichtiges Zitat...'),
          ),
          const _VerticalDivider(),
          _ToolbarIconButton(
            tooltip: 'Bild einfügen (Galerie, Kamera oder URL)',
            icon: Icons.add_photo_alternate_outlined,
            onTap: () => _showImagePickerModal(context),
          ),
          _ToolbarIconButton(
            tooltip: 'Inline Code',
            icon: Icons.code,
            onTap: () => appState.insertMarkdownSnippet('`', suffix: '`', defaultText: 'code()'),
          ),
          _ToolbarIconButton(
            tooltip: 'Code-Block (Fenced Block)',
            icon: Icons.terminal,
            onTap: () => appState.insertMarkdownSnippet('\n```dart\n', suffix: '\n```\n', defaultText: '// Quellcode hier'),
          ),
          _ToolbarIconButton(
            tooltip: 'Tabellen-Assistent (Raster, Vorlagen & Spalten)',
            icon: Icons.table_chart_outlined,
            onTap: () => _openTableAssistant(context),
          ),
          _ToolbarIconButton(
            tooltip: 'Weblink (URL)',
            icon: Icons.link,
            onTap: () => appState.insertMarkdownSnippet('[', suffix: '](https://example.com)', defaultText: 'Link-Text'),
          ),
          _ToolbarIconButton(
            tooltip: 'Horizontale Trennlinie',
            icon: Icons.horizontal_rule,
            onTap: () => appState.insertMarkdownSnippet('\n---\n'),
          ),
        ],
          ),
        );
      },
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onTap,
        splashRadius: 18,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      color: Colors.grey.shade300,
    );
  }
}
