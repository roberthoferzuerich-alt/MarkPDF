import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/app_state.dart';
import '../services/markdown_to_pdf_service.dart';

class PdfReaderScreen extends StatefulWidget {
  final AppState appState;

  const PdfReaderScreen({super.key, required this.appState});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  late final PdfViewerController _pdfViewerController;
  final TextEditingController _searchController = TextEditingController();
  PdfTextSearchResult? _searchResult;
  bool _isSearchActive = false;
  int _currentPage = 1;
  int _pageCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _generateAndOpenSample() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await MarkdownToPdfService.generatePdfBytes(
        widget.appState.markdownContent,
        title: 'MarkPDF Vorschau',
        themeType: widget.appState.selectedPdfTheme,
      );
      widget.appState.openGeneratedInReader(bytes, title: 'Generierte Markdown.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Generieren der PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _printCurrentPdf() async {
    final state = widget.appState;
    if (!state.hasReaderPdf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein PDF zum Drucken geöffnet.')),
      );
      return;
    }

    try {
      Uint8List? bytes = state.readerPdfBytes;
      if (bytes == null && state.readerPdfPath != null) {
        final file = File(state.readerPdfPath!);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      }

      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF-Daten konnten nicht geladen werden.')),
          );
        }
        return;
      }

      await Printing.layoutPdf(
        name: state.readerPdfTitle,
        onLayout: (format) async => bytes!,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Starten des Druckauftrags: $e')),
        );
      }
    }
  }

  void _startSearch(String query) {
    if (query.trim().isEmpty) return;
    _searchResult = _pdfViewerController.searchText(query);
    _searchResult?.addListener(() {
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  void _cancelSearch() {
    _searchResult?.clear();
    _searchController.clear();
    setState(() {
      _isSearchActive = false;
      _searchResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final hasPdf = state.hasReaderPdf;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'PDF durchsuchen...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchResult != null && _searchResult!.totalInstanceCount > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${_searchResult!.currentInstanceIndex} / ${_searchResult!.totalInstanceCount}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.arrow_upward, size: 20),
                        tooltip: 'Vorheriges Suchergebnis',
                        onPressed: _searchResult?.previousInstance,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward, size: 20),
                        tooltip: 'Nächstes Suchergebnis',
                        onPressed: _searchResult?.nextInstance,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Suche beenden',
                        onPressed: _cancelSearch,
                      ),
                    ],
                  ),
                ),
                onSubmitted: _startSearch,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PDF Reader',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (hasPdf)
                    Text(
                      state.readerPdfTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
        actions: [
          if (hasPdf && !_isSearchActive) ...[
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.search),
              tooltip: 'In PDF suchen',
              onPressed: () {
                setState(() => _isSearchActive = true);
              },
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.print_outlined),
              tooltip: 'PDF drucken',
              onPressed: _printCurrentPdf,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.zoom_in),
              tooltip: 'Zoom-Optionen',
              onSelected: (value) {
                final currentZoom = _pdfViewerController.zoomLevel;
                if (value == 'in') {
                  _pdfViewerController.zoomLevel = (currentZoom + 0.25).clamp(1.0, 3.0);
                } else if (value == 'out') {
                  if (currentZoom > 1.0) {
                    _pdfViewerController.zoomLevel = (currentZoom - 0.25).clamp(1.0, 3.0);
                  }
                } else if (value == 'reset') {
                  _pdfViewerController.zoomLevel = 1.0;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'in',
                  child: Row(
                    children: [
                      Icon(Icons.zoom_in, size: 20),
                      SizedBox(width: 10),
                      Text('Vergrößern (+25%)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'out',
                  child: Row(
                    children: [
                      Icon(Icons.zoom_out, size: 20),
                      SizedBox(width: 10),
                      Text('Verkleinern (-25%)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.restart_alt, size: 20),
                      SizedBox(width: 10),
                      Text('Zoom zurücksetzen (100%)'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.folder_open),
            tooltip: 'PDF öffnen',
            onPressed: () async {
              final opened = await state.pickAndOpenPdf();
              if (opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Geöffnet: ${state.readerPdfTitle}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !hasPdf
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Toolbar für Seitennavigation & Editor-Sprung (responsiv ohne Overflow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                icon: const Icon(Icons.chevron_left),
                                tooltip: 'Vorherige Seite',
                                onPressed: _currentPage > 1
                                    ? () => _pdfViewerController.previousPage()
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  'Seite $_currentPage von ${_pageCount > 0 ? _pageCount : "-"}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                icon: const Icon(Icons.chevron_right),
                                tooltip: 'Nächste Seite',
                                onPressed: _currentPage < _pageCount
                                    ? () => _pdfViewerController.nextPage()
                                    : null,
                              ),
                            ],
                          ),
                          Flexible(
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              icon: const Icon(Icons.edit_note, size: 20),
                              label: const Text(
                                'Editor',
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: () => state.setTabIndex(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // PDF Anzeige Widget
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade200,
                        child: state.readerPdfPath != null && !kIsWeb
                            ? SfPdfViewer.file(
                                File(state.readerPdfPath!),
                                controller: _pdfViewerController,
                                onDocumentLoaded: (details) {
                                  setState(() {
                                    _pageCount = details.document.pages.count;
                                  });
                                },
                                onPageChanged: (details) {
                                  setState(() {
                                    _currentPage = details.newPageNumber;
                                  });
                                },
                              )
                            : SfPdfViewer.memory(
                                state.readerPdfBytes!,
                                controller: _pdfViewerController,
                                onDocumentLoaded: (details) {
                                  setState(() {
                                    _pageCount = details.document.pages.count;
                                  });
                                },
                                onPageChanged: (details) {
                                  setState(() {
                                    _currentPage = details.newPageNumber;
                                  });
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.picture_as_pdf,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kein PDF-Dokument geöffnet',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Öffne eine lokale PDF-Datei vom Gerät oder wandle dein aktuelles Markdown in ein PDF um.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('PDF-Datei öffnen'),
                  onPressed: () => widget.appState.pickAndOpenPdf(),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.auto_stories),
                  label: const Text('Markdown als PDF anzeigen'),
                  onPressed: _generateAndOpenSample,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
