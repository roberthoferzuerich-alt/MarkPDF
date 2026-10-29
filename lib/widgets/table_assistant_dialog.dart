import 'package:flutter/material.dart';

/// Ausrichtung einer Tabellenspalte im Markdown.
enum TableColumnAlign {
  left('Links', Icons.format_align_left, ':---'),
  center('Zentriert', Icons.format_align_center, ':---:'),
  right('Rechts', Icons.format_align_right, '---:');

  final String label;
  final IconData icon;
  final String markdownSyntax;

  const TableColumnAlign(this.label, this.icon, this.markdownSyntax);
}

/// Eine vorgefertigte Vorlage für Tabellen.
class TablePreset {
  final String title;
  final String description;
  final IconData icon;
  final List<String> headers;
  final List<TableColumnAlign> alignments;
  final List<List<String>> sampleRows;

  const TablePreset({
    required this.title,
    required this.description,
    required this.icon,
    required this.headers,
    required this.alignments,
    required this.sampleRows,
  });
}

final List<TablePreset> kTablePresets = [
  const TablePreset(
    title: 'Einfach',
    description: '3 Spalten mit Standard-Einträgen',
    icon: Icons.grid_view,
    headers: ['Thema', 'Beschreibung', 'Status'],
    alignments: [TableColumnAlign.left, TableColumnAlign.left, TableColumnAlign.center],
    sampleRows: [
      ['Planung', 'Erstes Konzept erstellt', 'Erledigt'],
      ['Entwicklung', 'Frontend & PDF Pipeline', 'In Arbeit'],
      ['Test', 'Funktionstests auf Mobilgerät', 'Offen'],
    ],
  ),
  const TablePreset(
    title: 'Preisliste',
    description: 'Angebot oder Rechnung mit Beträgen',
    icon: Icons.receipt_long,
    headers: ['Pos.', 'Bezeichnung', 'Menge', 'Einzelpreis', 'Gesamt'],
    alignments: [
      TableColumnAlign.center,
      TableColumnAlign.left,
      TableColumnAlign.center,
      TableColumnAlign.right,
      TableColumnAlign.right,
    ],
    sampleRows: [
      ['1', 'MarkPDF Studio Lizenz', '1 Stk.', '49,00 €', '49,00 €'],
      ['2', 'Individuelle Vorlage', '2 Std.', '65,00 €', '130,00 €'],
      ['3', 'Wartung & Support (1 Jahr)', '1 Stk.', '80,00 €', '80,00 €'],
    ],
  ),
  const TablePreset(
    title: 'Aufgaben',
    description: 'Projekt- oder Team-Aufgabenliste',
    icon: Icons.task_alt,
    headers: ['Aufgabe', 'Priorität', 'Zuständig', 'Frist'],
    alignments: [
      TableColumnAlign.left,
      TableColumnAlign.center,
      TableColumnAlign.left,
      TableColumnAlign.center,
    ],
    sampleRows: [
      ['Release vorbereiten', 'Hoch', 'Robert', 'Morgen'],
      ['Dokumentation prüfen', 'Mittel', 'Team', 'Freitag'],
      ['Feedback einholen', 'Normal', 'Anna', 'Nächste Woche'],
    ],
  ),
  const TablePreset(
    title: 'Vergleich',
    description: 'Gegenüberstellung von Optionen',
    icon: Icons.compare_arrows,
    headers: ['Kriterium', 'Basis', 'Pro-Version'],
    alignments: [TableColumnAlign.left, TableColumnAlign.center, TableColumnAlign.center],
    sampleRows: [
      ['PDF Export', 'Standard', 'Ultra HD mit Themes'],
      ['Bilder zuschneiden', 'Nein', 'Ja (stufenlos)'],
      ['Tabellen-Assistent', 'Einfach', 'Vollwertig'],
    ],
  ),
];

/// Dialog für den Tabellen-Assistenten.
class TableAssistantDialog extends StatefulWidget {
  final Function(String markdownTable) onInsertTable;

  const TableAssistantDialog({
    super.key,
    required this.onInsertTable,
  });

  @override
  State<TableAssistantDialog> createState() => _TableAssistantDialogState();
}

class _TableAssistantDialogState extends State<TableAssistantDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tabellendaten
  int _columnCount = 3;
  int _rowCount = 3;
  List<TextEditingController> _headerControllers = [];
  List<TableColumnAlign> _alignments = [];
  List<List<TextEditingController>> _cellControllers = [];

  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _applyPreset(kTablePresets[0]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final c in _headerControllers) {
      c.dispose();
    }
    for (final row in _cellControllers) {
      for (final c in row) {
        c.dispose();
      }
    }
  }

  void _applyPreset(TablePreset preset) {
    _disposeControllers();
    _columnCount = preset.headers.length;
    _rowCount = preset.sampleRows.length;

    _headerControllers = preset.headers.map((h) => TextEditingController(text: h)).toList();
    _alignments = List.from(preset.alignments);

    _cellControllers = preset.sampleRows.map((row) {
      return row.map((cell) => TextEditingController(text: cell)).toList();
    }).toList();

    setState(() {});
  }

  void _updateColumnCount(int newCount) {
    if (newCount < 1 || newCount > 8) return;

    if (newCount > _columnCount) {
      for (int i = _columnCount; i < newCount; i++) {
        _headerControllers.add(TextEditingController(text: 'Spalte ${i + 1}'));
        _alignments.add(TableColumnAlign.left);
        for (final row in _cellControllers) {
          row.add(TextEditingController(text: ''));
        }
      }
    } else {
      while (_headerControllers.length > newCount) {
        _headerControllers.removeLast().dispose();
        _alignments.removeLast();
        for (final row in _cellControllers) {
          row.removeLast().dispose();
        }
      }
    }

    setState(() {
      _columnCount = newCount;
    });
  }

  void _updateRowCount(int newCount) {
    if (newCount < 1 || newCount > 20) return;

    if (newCount > _rowCount) {
      for (int i = _rowCount; i < newCount; i++) {
        final newRow = List.generate(
          _columnCount,
          (_) => TextEditingController(text: ''),
        );
        _cellControllers.add(newRow);
      }
    } else {
      while (_cellControllers.length > newCount) {
        final removedRow = _cellControllers.removeLast();
        for (final c in removedRow) {
          c.dispose();
        }
      }
    }

    setState(() {
      _rowCount = newCount;
    });
  }

  String _buildMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln();

    // 1. Kopfzeile
    buffer.write('|');
    for (int col = 0; col < _columnCount; col++) {
      final text = _headerControllers[col].text.trim().replaceAll('|', '\\|');
      buffer.write(' ${text.isEmpty ? "Spalte ${col + 1}" : text} |');
    }
    buffer.writeln();

    // 2. Trennzeile mit Ausrichtungen
    buffer.write('|');
    for (int col = 0; col < _columnCount; col++) {
      final align = col < _alignments.length ? _alignments[col] : TableColumnAlign.left;
      buffer.write(' ${align.markdownSyntax} |');
    }
    buffer.writeln();

    // 3. Datenzeilen
    for (int r = 0; r < _rowCount; r++) {
      buffer.write('|');
      final row = _cellControllers[r];
      for (int col = 0; col < _columnCount; col++) {
        final text = col < row.length ? row[col].text.trim().replaceAll('|', '\\|') : '';
        buffer.write(' $text |');
      }
      buffer.writeln();
    }
    buffer.writeln();

    return buffer.toString();
  }

  void _insertAndClose() {
    final markdown = _buildMarkdown();
    widget.onInsertTable(markdown);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.table_chart, color: colorScheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tabellen-Assistent',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_columnCount Spalten × $_rowCount Zeilen',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Schließen',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab-Leiste (Optionen vs. Zelleninhalt)
            TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              tabs: const [
                Tab(
                  icon: Icon(Icons.tune, size: 18),
                  text: 'Aufbau & Vorlagen',
                ),
                Tab(
                  icon: Icon(Icons.edit_note, size: 20),
                  text: 'Inhalte eingeben',
                ),
              ],
            ),

            // Tab-Inhalte
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStructureTab(theme, colorScheme),
                  _buildContentTab(theme, colorScheme, isDark),
                ],
              ),
            ),

            // Live Markdown-Vorschau (aufklappbar)
            if (_showPreview)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Markdown-Code Vorschau:',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _buildMarkdown().trim(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Footer / Aktionen (Vollständig responsiv via Wrap)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: Icon(
                      _showPreview ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 16,
                    ),
                    label: Text(_showPreview ? 'Code verbergen' : 'Code-Vorschau'),
                    onPressed: () => setState(() => _showPreview = !_showPreview),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tabelle einfügen'),
                    onPressed: _insertAndClose,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Tab: Vorlagen & Tabellenstruktur
  Widget _buildStructureTab(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vorlagen
          Text(
            'Vorlagen auswählen',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kTablePresets.map((preset) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(preset.icon, size: 16, color: colorScheme.primary),
                    label: Text(preset.title),
                    tooltip: preset.description,
                    onPressed: () => _applyPreset(preset),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Dimensionen (Spalten und Zeilen)
          Text(
            'Größe anpassen',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 440;
              final colCard = _buildCounterCard(
                title: 'Spalten',
                subtitle: '$_columnCount Spalten',
                value: _columnCount,
                min: 1,
                max: 8,
                onDecrement: () => _updateColumnCount(_columnCount - 1),
                onIncrement: () => _updateColumnCount(_columnCount + 1),
                theme: theme,
                colorScheme: colorScheme,
              );
              final rowCard = _buildCounterCard(
                title: 'Zeilen',
                subtitle: '$_rowCount Datenzeilen',
                value: _rowCount,
                min: 1,
                max: 20,
                onDecrement: () => _updateRowCount(_rowCount - 1),
                onIncrement: () => _updateRowCount(_rowCount + 1),
                theme: theme,
                colorScheme: colorScheme,
              );

              return isNarrow
                  ? Column(
                      children: [
                        colCard,
                        const SizedBox(height: 8),
                        rowCard,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: colCard),
                        const SizedBox(width: 10),
                        Expanded(child: rowCard),
                      ],
                    );
            },
          ),
          const SizedBox(height: 18),

          // Spalten-Header & Ausrichtung
          Text(
            'Spaltenüberschriften & Ausrichtung',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...List.generate(_columnCount, (index) {
            final align = index < _alignments.length ? _alignments[index] : TableColumnAlign.left;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _headerControllers[index],
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        labelText: 'Spalte ${index + 1}',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Kompakter 3-Icon-Umschalter für Textausrichtung (verhindert Überlauf)
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: TableColumnAlign.values.map((colAlign) {
                        final isSelected = align == colAlign;
                        return InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            setState(() {
                              _alignments[index] = colAlign;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              colAlign.icon,
                              size: 16,
                              color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 2. Tab: Zellen-Editor (Inhalte direkt bearbeiten)
  Widget _buildContentTab(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return Column(
      children: [
        // Steuerleiste über dem Raster
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Inhalte bearbeiten:',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Zeile +'),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                onPressed: _rowCount < 20 ? () => _updateRowCount(_rowCount + 1) : null,
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Zeile -'),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                onPressed: _rowCount > 1 ? () => _updateRowCount(_rowCount - 1) : null,
              ),
            ],
          ),
        ),

        // Scrollbares Raster
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              scrollDirection: Axis.vertical,
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(140),
                border: TableBorder.all(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                children: [
                  // Kopfzeile
                  TableRow(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    ),
                    children: List.generate(_columnCount, (col) {
                      return Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          _headerControllers[col].text.trim().isNotEmpty
                              ? _headerControllers[col].text.trim()
                              : 'Spalte ${col + 1}',
                          textAlign: _alignments[col] == TableColumnAlign.center
                              ? TextAlign.center
                              : _alignments[col] == TableColumnAlign.right
                                  ? TextAlign.right
                                  : TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      );
                    }),
                  ),

                  // Datenzeilen mit TextFields
                  ...List.generate(_rowCount, (rowIdx) {
                    final isEven = rowIdx % 2 == 0;
                    return TableRow(
                      decoration: BoxDecoration(
                        color: isEven
                            ? Colors.transparent
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                      ),
                      children: List.generate(_columnCount, (colIdx) {
                        final controller = _cellControllers[rowIdx][colIdx];
                        return Padding(
                          padding: const EdgeInsets.all(4),
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                              border: InputBorder.none,
                              hintText: '...',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Kompakte Zähler-Karte für Spalten und Zeilen (100% überlaufsicher)
  Widget _buildCounterCard({
    required String title,
    required String subtitle,
    required int value,
    required int min,
    required int max,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  onTap: value > min ? onDecrement : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: value > min ? colorScheme.primary : theme.disabledColor,
                    ),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 26),
                  alignment: Alignment.center,
                  child: Text(
                    '$value',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                InkWell(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  onTap: value < max ? onIncrement : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: value < max ? colorScheme.primary : theme.disabledColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
