import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/editor_background_style.dart';
import '../models/pdf_theme_config.dart';
import 'about_me_screen.dart';
import 'help_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AppState appState;

  const SettingsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Einstellungen',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // 1. Erscheinungsbild & Dark Mode
              _buildSectionHeader(context, 'Erscheinungsbild', Icons.palette_outlined),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Farbmodus (Dark Mode)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  'Wähle zwischen hellem, dunklem oder automatischem System-Modus.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<ThemeMode>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.brightness_auto, size: 18),
                                  label: Text('System'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode, size: 18),
                                  label: Text('Hell'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode, size: 18),
                                  label: Text('Dunkel'),
                                ),
                              ],
                              selected: {appState.themeMode},
                              onSelectionChanged: (newSelection) {
                                if (newSelection.isNotEmpty) {
                                  appState.setThemeMode(newSelection.first);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Markdown Editor Einstellungen
              _buildSectionHeader(context, 'Markdown-Editor', Icons.edit_note),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Schriftgröße im Editor',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (appState.editorFontSize != AppState.defaultEditorFontSize) ...[
                            IconButton(
                              icon: const Icon(Icons.restore, size: 20),
                              tooltip: 'Auf Standard (14 pt) zurücksetzen',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => appState.setEditorFontSize(AppState.defaultEditorFontSize),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              appState.editorFontSize == AppState.defaultEditorFontSize
                                  ? '${appState.editorFontSize.toInt()} pt · Standard'
                                  : '${appState.editorFontSize.toInt()} pt',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          tickMarkShape: _StandardFontTickMarkShape(
                            standardValue: AppState.defaultEditorFontSize,
                            min: 12.0,
                            max: 22.0,
                            primaryColor: colorScheme.primary,
                            tickColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                          ),
                        ),
                        child: Slider(
                          value: appState.editorFontSize,
                          min: 12.0,
                          max: 22.0,
                          divisions: 10,
                          label: appState.editorFontSize == AppState.defaultEditorFontSize
                              ? '${appState.editorFontSize.toInt()} pt (Standard)'
                              : '${appState.editorFontSize.toInt()} pt',
                          onChanged: (val) => appState.setEditorFontSize(val),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              '12 pt',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: appState.editorFontSize == AppState.defaultEditorFontSize
                                      ? null
                                      : () => appState.setEditorFontSize(AppState.defaultEditorFontSize),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: appState.editorFontSize == AppState.defaultEditorFontSize
                                          ? colorScheme.primaryContainer.withValues(alpha: 0.6)
                                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: appState.editorFontSize == AppState.defaultEditorFontSize
                                            ? colorScheme.primary.withValues(alpha: 0.6)
                                            : colorScheme.outlineVariant,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          appState.editorFontSize == AppState.defaultEditorFontSize
                                              ? Icons.bookmark_added_rounded
                                              : Icons.restore_rounded,
                                          size: 13,
                                          color: appState.editorFontSize == AppState.defaultEditorFontSize
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '14 pt (Standard)',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: appState.editorFontSize == AppState.defaultEditorFontSize
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '22 pt',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.gradient, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Editor-Hintergrund (Farbverlauf)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wähle einen augenschonenden Farbverlauf für die Schreibansicht im Markdown-Editor.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RadioGroup<EditorBackgroundStyle>(
                        groupValue: appState.editorBackgroundStyle,
                        onChanged: (val) {
                          if (val != null) appState.setEditorBackgroundStyle(val);
                        },
                        child: Column(
                          children: [
                            for (final style in EditorBackgroundStyle.values) ...[
                              Builder(
                                builder: (context) {
                                  final isSelected = appState.editorBackgroundStyle == style;
                                  final gradient = style.gradient(isDark);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => appState.setEditorBackgroundStyle(style),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? colorScheme.primary
                                                : (isDark ? Colors.white12 : Colors.grey.shade300),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          color: isSelected
                                              ? colorScheme.primaryContainer.withValues(alpha: 0.15)
                                              : Colors.transparent,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                gradient: gradient,
                                                color: gradient == null
                                                    ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                                    : null,
                                                border: Border.all(
                                                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Icon(
                                                style.icon,
                                                size: 18,
                                                color: isDark ? Colors.white70 : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Wrap(
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    spacing: 6,
                                                    runSpacing: 2,
                                                    children: [
                                                      Text(
                                                        style.label,
                                                        style: TextStyle(
                                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      if (style == EditorBackgroundStyle.subtleBlue)
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: const Text(
                                                            'Empfohlen',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF2563EB),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    style.description,
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: colorScheme.onSurfaceVariant,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Radio<EditorBackgroundStyle>(
                                              value: style,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Divider(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.restart_alt, color: Colors.blue),
                        title: const Text('Muster-Vorlage wiederherstellen'),
                        subtitle: const Text('Tippen, um den Text im Editor auf Standard zurückzusetzen.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          appState.resetToSample();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Muster-Vorlage wiederhergestellt!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. PDF Export Theme
              _buildSectionHeader(context, 'Standard-PDF-Theme', Icons.picture_as_pdf_outlined),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: RadioGroup<PdfThemeType>(
                    groupValue: appState.selectedPdfTheme,
                    onChanged: (val) {
                      if (val != null) appState.setPdfTheme(val);
                    },
                        child: Column(
                          children: [
                            for (final themeType in PdfThemeType.values) ...[
                              Builder(
                                builder: (context) {
                                  final config = PdfThemeConfig.fromType(themeType);
                                  return RadioListTile<PdfThemeType>(
                                    value: themeType,
                                    secondary: Icon(config.icon, color: colorScheme.primary),
                                    title: Text(
                                      config.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      config.subtitle,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Link zum "Hilfe & Handbuch" Screen mit dezentem blauen Farbverlauf
              _buildSectionHeader(context, 'Hilfe & Handbuch', Icons.auto_stories_outlined),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                              const Color(0xFF0F172A),
                            ]
                          : [
                              const Color(0xFFEFF6FF),
                              const Color(0xFFDBEAFE),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    const Text(
                                      'Hilfe & Benutzerhandbuch',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Anleitung',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ausführliche Schritt-für-Schritt-Anleitung zu Markdown, Tabellen-Editor, Bildzuschnitt, 5 PDF-Themes & Tastaturkürzeln.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Link zum "Über mich" Screen
              _buildSectionHeader(context, 'Über & Information', Icons.info_outline),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutMeScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  const Text(
                                    'Über mich & MarkPDF',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Profil',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Entwickler-Infos, Vision, Feature-Details & Kontakt.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Version Info
              Center(
                child: Text(
                  'MarkPDF v1.1.0 · 100% Offline & Open-Source',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Ein individueller TickMarkShape für den Schriftgrößen-Regler,
/// der die Standard-Schriftgröße (14 pt) optisch hervorhebt.
class _StandardFontTickMarkShape extends SliderTickMarkShape {
  const _StandardFontTickMarkShape({
    required this.standardValue,
    required this.min,
    required this.max,
    required this.primaryColor,
    required this.tickColor,
  });

  static const double standardTickWidth = 3.5;
  static const double standardTickHeight = 14.0;
  static const double regularTickRadius = 2.0;

  final double standardValue;
  final double min;
  final double max;
  final Color primaryColor;
  final Color tickColor;

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    required bool isEnabled,
  }) {
    return Size.fromRadius(regularTickRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    required bool isEnabled,
  }) {
    final trackRect = (sliderTheme.trackShape ?? const RoundedRectSliderTrackShape())
        .getPreferredRect(parentBox: parentBox, sliderTheme: sliderTheme);

    final double progress = trackRect.width > 0
        ? (textDirection == TextDirection.rtl
                ? (trackRect.right - center.dx)
                : (center.dx - trackRect.left)) /
            trackRect.width
        : 0.0;

    final double tickValue = min + progress.clamp(0.0, 1.0) * (max - min);
    final bool isStandard = (tickValue - standardValue).abs() < 0.25;

    final canvas = context.canvas;

    if (isStandard) {
      // Prominenter vertikaler Markierungs-Pill für die Standard-Schriftgröße (14 pt)
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: standardTickWidth,
          height: standardTickHeight,
        ),
        const Radius.circular(2.0),
      );
      canvas.drawRRect(rrect, Paint()..color = primaryColor);

      // Kleiner Zeiger-Marker direkt über der Markierung
      final trianglePath = Path()
        ..moveTo(center.dx - 3.5, center.dy - 8.5)
        ..lineTo(center.dx + 3.5, center.dy - 8.5)
        ..lineTo(center.dx, center.dy - 4.5)
        ..close();
      canvas.drawPath(trianglePath, Paint()..color = primaryColor);
    } else {
      // Dezenter Punkt für reguläre Ticks
      canvas.drawCircle(center, regularTickRadius, Paint()..color = tickColor);
    }
  }
}

