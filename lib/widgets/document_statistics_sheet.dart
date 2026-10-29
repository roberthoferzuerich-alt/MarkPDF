import 'package:flutter/material.dart';
import '../models/document_statistics.dart';

/// Zeigt ein ansprechendes Modal mit den Dokument-Statistiken an.
class DocumentStatisticsSheet extends StatelessWidget {
  final DocumentStatistics statistics;

  const DocumentStatisticsSheet({
    super.key,
    required this.statistics,
  });

  static Future<void> show(BuildContext context, DocumentStatistics statistics) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DocumentStatisticsSheet(statistics: statistics),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.analytics_outlined, color: colorScheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dokument-Statistiken',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Echtzeit-Analyse des aktuellen Inhalts',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
              const SizedBox(height: 16),

              // 1. Haupt-KPIs (Wörter, Lesezeit & Zeilen)
              Row(
                children: [
                  Expanded(
                    child: _buildHeroCard(
                      label: 'Wörter',
                      value: '${statistics.words}',
                      icon: Icons.notes,
                      color: Colors.blue,
                      theme: theme,
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildHeroCard(
                      label: 'Lesezeit',
                      value: '~${statistics.readingTimeMinutes} Min.',
                      icon: Icons.timer_outlined,
                      color: Colors.teal,
                      theme: theme,
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildHeroCard(
                      label: 'Zeilen',
                      value: '${statistics.lines}',
                      icon: Icons.format_list_numbered,
                      color: Colors.indigo,
                      theme: theme,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Detailkarten
              _buildDetailSection(
                title: 'Textumfang',
                icon: Icons.format_shapes,
                theme: theme,
                colorScheme: colorScheme,
                items: [
                  _StatItem('Wörter gesamt', '${statistics.words}'),
                  _StatItem('Zeichen (inkl. Leerzeichen)', '${statistics.charactersWithSpaces}'),
                  _StatItem('Zeichen (ohne Leerzeichen)', '${statistics.charactersWithoutSpaces}'),
                ],
              ),
              const SizedBox(height: 10),

              _buildDetailSection(
                title: 'Lese- & Vortragszeit',
                icon: Icons.schedule,
                theme: theme,
                colorScheme: colorScheme,
                items: [
                  _StatItem('Geschätzte Lesezeit', 'ca. ${statistics.readingTimeMinutes} Min. (bei 200 WpM)'),
                  _StatItem('Geschätzte Sprechzeit', 'ca. ${statistics.speakingTimeMinutes} Min. (bei 130 WpM)'),
                ],
              ),
              const SizedBox(height: 10),

              _buildDetailSection(
                title: 'Struktur & Formatierung',
                icon: Icons.account_tree_outlined,
                theme: theme,
                colorScheme: colorScheme,
                items: [
                  _StatItem('Absätze', '${statistics.paragraphs}'),
                  _StatItem('Zeilen', '${statistics.lines}'),
                  _StatItem('Überschriften (H1–H6)', '${statistics.headingsCount}'),
                  _StatItem('Eingebettete Bilder', '${statistics.imagesCount}'),
                  _StatItem('Tabellen', '${statistics.tablesCount}'),
                  _StatItem('Code-Blöcke', '${statistics.codeBlocksCount}'),
                ],
              ),
              const SizedBox(height: 16),

              // Schließen Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Schließen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required List<_StatItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                    Text(
                      item.value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);
}
