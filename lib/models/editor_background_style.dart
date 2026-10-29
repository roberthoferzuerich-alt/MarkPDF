import 'package:flutter/material.dart';

/// Definiert verschiedene Hintergrund-Stile (inklusive dezenten Farbverläufen)
/// für den Markdown-Editor.
enum EditorBackgroundStyle {
  none(
    id: 'none',
    label: 'Klassisch',
    description: 'Einfarbig schlicht ohne Verlauf',
    icon: Icons.crop_portrait,
    lightColors: null,
    darkColors: null,
  ),
  subtleBlue(
    id: 'subtleBlue',
    label: 'Dezentes Blau',
    description: 'Sanfter, konzentrierter blauer Farbverlauf',
    icon: Icons.water_drop_outlined,
    lightColors: [
      Color(0xFFF0F7FF), // Zartes Himmelsblau
      Color(0xFFE0F2FE), // Sanftes Cyan-Blau
      Color(0xFFF8FAFC), // Sanfter Übergang zu Slate-50
    ],
    darkColors: [
      Color(0xFF0F172A), // Slate 900
      Color(0xFF1E293B), // Slate 800
      Color(0xFF132338), // Dezent tiefes Mitternachtsblau
    ],
  ),
  oceanTeal(
    id: 'oceanTeal',
    label: 'Ozean & Teal',
    description: 'Frischer Blau-Grün-Verlauf für Kreativität',
    icon: Icons.waves,
    lightColors: [
      Color(0xFFF0FDFA), // Mint/Teal zart
      Color(0xFFCCFBF1), // Sanftes Türkis
      Color(0xFFF0FDF4), // Hauch von Mintgrün
    ],
    darkColors: [
      Color(0xFF0F172A),
      Color(0xFF0F2D2A),
      Color(0xFF062B28),
    ],
  ),
  softLavender(
    id: 'softLavender',
    label: 'Sanftes Lavendel',
    description: 'Beruhigender, warmer Pastell-Farbverlauf',
    icon: Icons.palette_outlined,
    lightColors: [
      Color(0xFFFAF5FF), // Zartes Lila/Lavendel
      Color(0xFFF3E8FF), // Pastell Violett
      Color(0xFFFDF2F8), // Zartes Rosé
    ],
    darkColors: [
      Color(0xFF0F172A),
      Color(0xFF221738),
      Color(0xFF1A152E),
    ],
  ),
  warmAmber(
    id: 'warmAmber',
    label: 'Warmes Papier',
    description: 'Gemütlicher, warmer Notizbuch-Verlauf',
    icon: Icons.auto_stories_outlined,
    lightColors: [
      Color(0xFFFFFDF5), // Zartes Creme
      Color(0xFFFEF3C7), // Warmes Amber 100
      Color(0xFFFFFBEB), // Sanftes Pergament
    ],
    darkColors: [
      Color(0xFF1C1917), // Stone 900
      Color(0xFF292524), // Stone 800
      Color(0xFF1F1B18),
    ],
  );

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final List<Color>? lightColors;
  final List<Color>? darkColors;

  const EditorBackgroundStyle({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.lightColors,
    required this.darkColors,
  });

  /// Gibt den [LinearGradient] für den aktuellen [isDark]-Modus zurück,
  /// oder `null`, falls der klassische einfarbige Hintergrund gewählt ist.
  LinearGradient? gradient(bool isDark) {
    final colors = isDark ? darkColors : lightColors;
    if (colors == null) return null;
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Farbvorschau für Icons oder Chips in den Einstellungen.
  Color previewColor(bool isDark) {
    final colors = isDark ? darkColors : lightColors;
    if (colors == null || colors.isEmpty) {
      return isDark ? const Color(0xFF1E293B) : Colors.white;
    }
    return colors[0];
  }
}
