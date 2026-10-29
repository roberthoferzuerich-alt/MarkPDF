import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/app_state.dart';
import '../models/pdf_theme_config.dart';
import '../services/file_service.dart';
import '../services/markdown_to_pdf_service.dart';

class PdfPreviewScreen extends StatefulWidget {
  final AppState appState;

  const PdfPreviewScreen({super.key, required this.appState});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  PdfPageFormat _pageFormat = PdfPageFormat.a4;
  bool _isSaving = false;

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final bytes = await MarkdownToPdfService.generatePdfBytes(
      widget.appState.markdownContent,
      title: 'MarkPDF Dokument',
      pageFormat: format,
      themeType: widget.appState.selectedPdfTheme,
    );
    widget.appState.setLastGeneratedPdf(bytes);
    return bytes;
  }

  Future<void> _savePdfLocally() async {
    setState(() => _isSaving = true);
    try {
      final bytes = widget.appState.lastGeneratedPdfBytes ??
          await MarkdownToPdfService.generatePdfBytes(
            widget.appState.markdownContent,
            title: 'MarkPDF Dokument',
            pageFormat: _pageFormat,
            themeType: widget.appState.selectedPdfTheme,
          );

      final path = await FileService.savePdfFile(bytes, defaultFileName: 'dokument.pdf');
      if (mounted) {
        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF erfolgreich gespeichert:\n$path'),
              action: SnackBarAction(
                label: 'Im Reader ansehen',
                onPressed: () {
                  widget.appState.openGeneratedInReader(bytes, title: 'dokument.pdf');
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speichervorgang abgebrochen.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openInReader() async {
    final bytes = widget.appState.lastGeneratedPdfBytes ??
        await MarkdownToPdfService.generatePdfBytes(
          widget.appState.markdownContent,
          title: 'MarkPDF Dokument',
          pageFormat: _pageFormat,
          themeType: widget.appState.selectedPdfTheme,
        );

    widget.appState.openGeneratedInReader(bytes, title: 'Exportierte Markdown-PDF');
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PDF Design-Theme wählen',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Wähle Typografie und Farbgebung für den fertigen PDF-Ausdruck:',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ...PdfThemeConfig.allThemes.map((theme) {
                  final isSelected = widget.appState.selectedPdfTheme == theme.type;
                  final primaryRgb = Color.fromARGB(
                    255,
                    (theme.primaryColor.red * 255).round(),
                    (theme.primaryColor.green * 255).round(),
                    (theme.primaryColor.blue * 255).round(),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        widget.appState.setPdfTheme(theme.type);
                        Navigator.pop(bottomSheetContext);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryRgb.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(theme.icon, color: primaryRgb, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        theme.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.black87,
                                        ),
                                      ),
                                      if (theme.isSerif) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('Serif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    theme.subtitle,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PDF Vorschau',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Theme-Auswahl Button
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'PDF Design-Theme wählen',
            onPressed: () => _showThemePicker(context),
          ),

          // Format-Auswahl A4 / Letter
          DropdownButtonHideUnderline(
            child: DropdownButton<PdfPageFormat>(
              value: _pageFormat,
              dropdownColor: theme.colorScheme.surface,
              items: const [
                DropdownMenuItem(
                  value: PdfPageFormat.a4,
                  child: Text('A4', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                DropdownMenuItem(
                  value: PdfPageFormat.letter,
                  child: Text('Letter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
              onChanged: (newFormat) {
                if (newFormat != null) {
                  setState(() => _pageFormat = newFormat);
                }
              },
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chrome_reader_mode_outlined),
            tooltip: 'Im Reader öffnen',
            onPressed: _openInReader,
          ),
          if (!kIsWeb)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              tooltip: 'PDF speichern',
              onPressed: _isSaving ? null : _savePdfLocally,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: widget.appState.markdownContent.trim().isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Kein Markdown-Inhalt vorhanden',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Wechsle in den Editor und schreibe etwas Text.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Zum Editor wechseln'),
                    onPressed: () => widget.appState.setTabIndex(1),
                  ),
                ],
              ),
            )
          : ListenableBuilder(
              listenable: widget.appState,
              builder: (context, _) {
                return PdfPreview(
                  // Eindeutiger Key sorgt für sauberen Neuaufbau beim Theme-Wechsel
                  key: ValueKey('${widget.appState.selectedPdfTheme}_$_pageFormat'),
                  build: (format) => _generatePdf(format),
                  initialPageFormat: _pageFormat,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  loadingWidget: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('PDF wird mit Theme gerendert...'),
                      ],
                    ),
                  ),
                  actions: [
                    PdfPreviewAction(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: (context, build, pageFormat) async {
                        await _openInReader();
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
