import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Alle';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Alle',
    'Schnellstart',
    'Markdown',
    'Tabellen',
    'Bilder',
    'PDF & Themes',
    'Reader',
    'Shortcuts',
    'FAQ',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dezenter blauer Farbverlauf für den Screen-Hintergrund
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? const [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF132238), // Dezent bläulicher Schimmer
              Color(0xFF0B132B), // Deep Midnight Blue
            ]
          : const [
              Color(0xFFF0F7FF), // Sanftes Himmelsblau
              Color(0xFFE0F2FE), // Dezent helles Blau
              Color(0xFFF8FAFC), // Weicher Übergang
            ],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Hilfe & Benutzerhandbuch',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Hero Banner & Suchleiste
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    _buildHeroCard(context, isDark),
                    const SizedBox(height: 12),
                    _buildSearchBar(context, isDark),
                    const SizedBox(height: 10),
                    _buildCategoryFilter(context, isDark),
                  ],
                ),
              ),

              // Content-Liste mit den ausführlichen Anleitungen
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: _buildFilteredSections(context, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                  const Color(0xFF0F172A).withValues(alpha: 0.8),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  const Color(0xFFDBEAFE).withValues(alpha: 0.85),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.3) : const Color(0xFF93C5FD).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'MarkPDF Handbuch',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'v1.1.0',
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
                  'Ausführliche Benutzeranleitung für Editor, Tabellen, Bilder, PDF-Export & Tastenkombinationen.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _searchController,
      onChanged: (val) {
        setState(() {
          _searchQuery = val.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.9),
        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        hintText: 'Im Handbuch suchen (z. B. Tabelle, Bild, Theme)...',
        hintStyle: TextStyle(fontSize: 13, color: colorScheme.outline),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(cat),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF2563EB),
              backgroundColor: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : (isDark ? Colors.white12 : Colors.grey.shade300),
                ),
              ),
              showCheckmark: false,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildFilteredSections(BuildContext context, bool isDark) {
    final sections = <_HelpSectionData>[
      _getQuickStartSection(),
      _getMarkdownFormattingSection(),
      _getTableAssistantSection(),
      _getImageEditorSection(),
      _getPdfThemesSection(),
      _getPdfReaderSection(),
      _getCustomizationSection(),
      _getShortcutsSection(),
      _getFaqSection(),
    ];

    final filtered = sections.where((sec) {
      // 1. Kategoriefilter
      if (_selectedCategory != 'Alle' && sec.category != _selectedCategory) {
        return false;
      }
      // 2. Suchfilter
      if (_searchQuery.isNotEmpty) {
        final matchesTitle = sec.title.toLowerCase().contains(_searchQuery);
        final matchesSubtitle = sec.subtitle.toLowerCase().contains(_searchQuery);
        final matchesKeywords = sec.keywords.any((k) => k.toLowerCase().contains(_searchQuery));
        final matchesContent = sec.plainContent.toLowerCase().contains(_searchQuery);
        return matchesTitle || matchesSubtitle || matchesKeywords || matchesContent;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, size: 54, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 12),
                const Text(
                  'Keine passenden Themen gefunden',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Versuche einen anderen Suchbegriff oder setze den Filter auf "Alle" zurück.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCategory = 'Alle';
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Filter zurücksetzen'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return filtered.map((sec) => _buildHelpCard(context, sec, isDark)).toList();
  }

  Widget _buildHelpCard(BuildContext context, _HelpSectionData data, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : Colors.blue.shade100,
            width: 0.8,
          ),
        ),
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.92),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: _searchQuery.isNotEmpty || data.initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: data.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: data.gradientColors[0].withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(data.icon, color: Colors.white, size: 22),
            ),
            title: Text(
              data.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                data.subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: data.contentWidgets,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // INHALTE DER EINZELNEN HANDBUCH-SEKTIONEN
  // ==========================================

  _HelpSectionData _getQuickStartSection() {
    return _HelpSectionData(
      category: 'Schnellstart',
      title: '1. Schnelleinstieg in 3 Schritten',
      subtitle: 'In wenigen Sekunden vom Entwurf zum druckreifen PDF',
      icon: Icons.rocket_launch_rounded,
      initiallyExpanded: true,
      gradientColors: const [Color(0xFF2563EB), Color(0xFF0284C7)],
      keywords: ['start', 'schnellstart', 'anfang', 'workflow', 'einführung'],
      plainContent: 'Text erfassen, Elemente einfügen und PDF exportieren.',
      contentWidgets: [
        const SizedBox(height: 8),
        _buildStepTile(
          stepNumber: '1',
          title: 'Text im Markdown-Editor verfassen',
          description:
              'Nutze den integrierten Editor für einfache Notizen oder strukturierte Dokumente. Verwende die Formatierungs-Toolbar am oberen Rand für schnelle Überschriften, Listen und Zitate.',
          icon: Icons.edit_note,
        ),
        const SizedBox(height: 10),
        _buildStepTile(
          stepNumber: '2',
          title: 'Tabellen & Bilder hinzufügen',
          description:
              'Erstelle saubere Tabellen mit dem visuellen Tabellen-Assistenten und schneide Fotos direkt im integrierten Bild-Editor auf das perfekte Seitenverhältnis (1:1, 4:3, 16:9) zu.',
          icon: Icons.table_chart_outlined,
        ),
        const SizedBox(height: 10),
        _buildStepTile(
          stepNumber: '3',
          title: 'PDF generieren & drucken / teilen',
          description:
              'Wechsle zum Tab "Vorschau / Export". Wähle aus 5 eleganten Design-Vorlagen (z. B. Modern Business oder Clean Technical) und exportiere dein PDF auf Knopfdruck oder drucke es direkt aus.',
          icon: Icons.picture_as_pdf,
        ),
      ],
    );
  }

  _HelpSectionData _getMarkdownFormattingSection() {
    return _HelpSectionData(
      category: 'Markdown',
      title: '2. Markdown Textformatierung',
      subtitle: 'Überschriften, Textstile, Listen, Zitate & Codeblöcke',
      icon: Icons.format_paint_rounded,
      gradientColors: const [Color(0xFF0D9488), Color(0xFF10B981)],
      keywords: ['markdown', 'fett', 'kursiv', 'überschrift', 'liste', 'zitat', 'code'],
      plainContent: 'Überschriften mit #, Fett mit **, Kursiv mit *, Durchgestrichen mit ~~, Listen und Zitate.',
      contentWidgets: [
        const SizedBox(height: 8),
        const Text(
          'MarkPDF unterstützt die vollständige GitHub-Flavored-Markdown-Syntax. Hier sind die wichtigsten Syntax-Elemente im Überblick:',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        _buildSyntaxRow('# Überschrift 1', 'Große Hauptüberschrift (H1)'),
        _buildSyntaxRow('## Überschrift 2', 'Abschnittsüberschrift (H2)'),
        _buildSyntaxRow('### Überschrift 3', 'Unterüberschrift (H3)'),
        _buildSyntaxRow('**Fetter Text**', 'Hervorhebung in Fettschrift'),
        _buildSyntaxRow('*Kursiver Text*', 'Schräggestellter Text'),
        _buildSyntaxRow('~~Durchgestrichen~~', 'Text als korrigiert markieren'),
        _buildSyntaxRow('> Wichtiges Zitat', 'Hervorgehobener Zitatblock'),
        _buildSyntaxRow('---', 'Horizontale Trennlinie'),
        _buildSyntaxRow('- [x] Erledigte Aufgabe', 'Interaktive Checkliste'),
        _buildSyntaxRow('- [ ] Offene Aufgabe', 'Unerledigter To-Do-Punkt'),
        _buildSyntaxRow('`inline_code()`', 'Code-Hervorhebung im Satz'),
        _buildSyntaxRow('```dart\nvoid main() {}\n```', 'Mehrzeiliger Codeblock mit Syntax-Box'),
        _buildSyntaxRow('[Google](https://google.com)', 'Klickbarer Hyperlink'),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Tipp: Nutze die Schnell-Toolbar über der Tastatur! Mit einem Tipp auf das jeweilige Symbol wird die gewünschte Formatierung automatisch an deiner Cursorposition eingefügt.',
          Icons.lightbulb_outline,
        ),
      ],
    );
  }

  _HelpSectionData _getTableAssistantSection() {
    return _HelpSectionData(
      category: 'Tabellen',
      title: '3. Interaktiver Tabellen-Assistent',
      subtitle: 'Komplexe Tabellen visuell erstellen ohne fehleranfällige Pipes',
      icon: Icons.table_view_rounded,
      gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      keywords: ['tabelle', 'spalten', 'zeilen', 'ausrichtung', 'grid', 'table'],
      plainContent: 'Visueller Tabellen-Editor, Zeilen und Spalten hinzufügen, Ausrichtung festlegen und 1-Klick-Übernahme.',
      contentWidgets: [
        const SizedBox(height: 8),
        const Text(
          'Tabellen per Hand in Markdown zu schreiben erfordert viele senkrechte Striche (|) und Bindestriche (-). Der integrierte Tabellen-Assistent nimmt dir diese Arbeit vollständig ab:',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.view_column_outlined,
          title: 'Dynamische Spalten & Zeilen',
          description: 'Füge beliebig viele Spalten und Zeilen per Tastendruck hinzu oder entferne sie mit dem Papierkorb-Symbol.',
        ),
        _buildFeatureItem(
          icon: Icons.format_align_center,
          title: 'Textausrichtung pro Spalte',
          description: 'Bestimme für jede Spalte individuell, ob der Text linksbündig, zentriert oder rechtsbündig formatiert werden soll.',
        ),
        _buildFeatureItem(
          icon: Icons.visibility_outlined,
          title: 'Live-Vorschau in Echtzeit',
          description: 'Unterhalb der Eingabefelder siehst du sofort, wie deine fertige Tabelle im Dokument aussehen wird.',
        ),
        _buildFeatureItem(
          icon: Icons.check_circle_outline,
          title: '1-Klick-Einfügen in den Editor',
          description: 'Tippe auf "Tabelle einfügen", und der perfekte Markdown-Code wird an der aktuellen Cursorposition platziert.',
        ),
      ],
    );
  }

  _HelpSectionData _getImageEditorSection() {
    return _HelpSectionData(
      category: 'Bilder',
      title: '4. Bilder & Foto-Zuschnitt-Editor',
      subtitle: 'Fotos aufnehmen oder wählen, drehen, zuschneiden & skalieren',
      icon: Icons.image_rounded,
      gradientColors: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
      keywords: ['bild', 'foto', 'zuschneiden', 'crop', 'kamera', 'galerie', 'skalieren'],
      plainContent: 'Fotos aus Galerie oder Kamera, Zuschnitt mit Seitenverhältnis 1:1, 4:3, 16:9, Drehung und Web-Skalierung.',
      contentWidgets: [
        const SizedBox(height: 8),
        const Text(
          'MarkPDF ermöglicht das nahtlose Einbinden von Bildern aus der lokalen Gerätegalerie oder direkt von der Kamera. Vor dem Einfügen steht dir ein leistungsstarker Editor zur Verfügung:',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.aspect_ratio,
          title: 'Präziser Zuschnitt (Crop)',
          description: 'Wähle feste Seitenverhältnisse wie 1:1 (Quadrat), 4:3 (Standardfoto), 16:9 (Breitbild) oder passe den Ausschnitt völlig frei an.',
        ),
        _buildFeatureItem(
          icon: Icons.rotate_right,
          title: '90°-Schritt Rotation',
          description: 'Drehe falsch ausgerichtete Smartphone-Fotos vor dem Einfügen ganz einfach in die richtige Position.',
        ),
        _buildFeatureItem(
          icon: Icons.compress,
          title: 'Automatische Bildoptimierung',
          description: 'MarkPDF skaliert hochauflösende Fotos auf eine druckoptimierte Größe herunter. Dadurch bleiben generierte PDFs angenehm klein und lassen sich blitzschnell versenden.',
        ),
        _buildFeatureItem(
          icon: Icons.short_text,
          title: 'Automatische Markdown-Verknüpfung',
          description: 'Das Bild wird im lokalen App-Speicher gesichert und als `![Alt-Text](lokaler_pfad)` direkt in deinen Text eingesetzt.',
        ),
      ],
    );
  }

  _HelpSectionData _getPdfThemesSection() {
    return _HelpSectionData(
      category: 'PDF & Themes',
      title: '5. PDF-Export & Design-Themes',
      subtitle: 'Die 5 professionellen Vorlagen, Druckseitenaufteilung & Teilen',
      icon: Icons.picture_as_pdf_rounded,
      gradientColors: const [Color(0xFF2563EB), Color(0xFF4F46E5)],
      keywords: ['pdf', 'theme', 'export', 'design', 'drucken', 'teilen', 'vorlage'],
      plainContent: 'Modern Business, Elegant Editorial, Clean Technical, Minimalist, Creative Pastel. A4 Druckseitenaufteilung.',
      contentWidgets: [
        const SizedBox(height: 8),
        const Text(
          'Verwandle deinen Rohtext in ein makelloses A4-Dokument. Wähle aus fünf speziell gestalteten Layouts:',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        _buildThemeCard(
          title: 'Modern Business',
          description: 'Klassisches Königsblau, klare serifenlose Typografie und dezent akzentuierte Tabellen. Die perfekte Wahl für Angebote, Rechnungen und geschäftliche Berichte.',
          color: const Color(0xFF2563EB),
          icon: Icons.business_center,
        ),
        _buildThemeCard(
          title: 'Elegant Editorial',
          description: 'Traditionelle Serifenschrift mit edlem Rahmenkopf. Ideal für Artikel, Essays, Monographien und literarische Texte.',
          color: const Color(0xFF7C2D12),
          icon: Icons.menu_book,
        ),
        _buildThemeCard(
          title: 'Clean Technical',
          description: 'Monospace-Fokus mit frischen Teal-Akzenten. Hervorragend geeignet für Programmier-Tutorials, Schnittstellen-Dokumentationen und technische Spezifikationen.',
          color: const Color(0xFF0D9488),
          icon: Icons.code,
        ),
        _buildThemeCard(
          title: 'Minimalist',
          description: 'Pures Schwarz-Weiß mit hohem Weißraumanteil. Maximal augenschonend, elegant und extrem sparsam beim Ausdrucken.',
          color: const Color(0xFF334155),
          icon: Icons.format_clear,
        ),
        _buildThemeCard(
          title: 'Creative Pastel',
          description: 'Moderne Pastelltöne in Sanftviolett und Zartblau. Perfekt für kreative Notizen, Projekt-Pitches und Zusammenfassungen.',
          color: const Color(0xFF7E22CE),
          icon: Icons.palette,
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Export-Features: Automatische Seitennummerierung ("Seite X von Y"), anpassbare A4-Seitenumbrüche, PDF-Vorschau mit Zoom, lokales Abspeichern und Direktversand über das Teilen-Menü.',
          Icons.print_outlined,
        ),
      ],
    );
  }

  _HelpSectionData _getPdfReaderSection() {
    return _HelpSectionData(
      category: 'Reader',
      title: '6. Integrierter PDF-Reader',
      subtitle: 'Beliebige PDFs öffnen, durchblättern & zoomen',
      icon: Icons.chrome_reader_mode_rounded,
      gradientColors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
      keywords: ['reader', 'pdf', 'öffnen', 'lesen', 'zoom', 'blätter'],
      plainContent: 'Lokale PDF-Dateien öffnen, zoomen, blättern und generierte Dokumente direkt prüfen.',
      contentWidgets: [
        const SizedBox(height: 8),
        const Text(
          'MarkPDF enthält einen vollständigen, performanten PDF-Viewer, mit dem du jede beliebige PDF-Datei ohne Internetverbindung öffnen und lesen kannst:',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.file_open_outlined,
          title: 'Eigene PDF-Dateien öffnen',
          description: 'Öffne vorhandene Dokumente von deinem Speicher oder aus Downloads mit einem Tipp auf das Datei-Symbol im Reader.',
        ),
        _buildFeatureItem(
          icon: Icons.zoom_in,
          title: 'Flüssiger Zoom & Blättern',
          description: 'Stufenloser Pinch-to-Zoom für kleinste Textdetails, vertikales und horizontales Scrollen sowie Anzeige der aktuellen Seitenzahl.',
        ),
        _buildFeatureItem(
          icon: Icons.swap_horiz,
          title: 'Direktübernahme aus dem Editor',
          description: 'Klicke im Vorschau-Screen auf "Im Reader öffnen", um dein frisch erstelltes Dokument sofort im Lese-Modus zu prüfen.',
        ),
      ],
    );
  }

  _HelpSectionData _getCustomizationSection() {
    return _HelpSectionData(
      category: 'Optionen',
      title: '7. Personalisierung & Editor-Farbverläufe',
      subtitle: 'Hintergrund-Farbverlauf für den Editor, Schriftgrößen & Dark Mode',
      icon: Icons.tune_rounded,
      gradientColors: const [Color(0xFF0EA5E9), Color(0xFF2563EB)],
      keywords: ['farbverlauf', 'hintergrund', 'farbmodus', 'dark mode', 'schriftgröße', 'anpassung'],
      plainContent: 'Dezenter blauer Farbverlauf für den Editor, anpassbare Schriftgröße (12-22 pt), Dark Mode.',
      contentWidgets: [
        const SizedBox(height: 8),
        const Text(
          'Passe die App genau an deine Vorlieben und deine Arbeitsweise an:',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.gradient,
          title: 'Editor Hintergrund-Farbverlauf',
          description: 'Aktiviere in den Einstellungen einen sanften, augenschonenden Farbverlauf für den Markdown-Editor (z. B. "Dezentes Blau", "Ozean & Teal" oder "Sanftes Lavendel") für ein besonders angenehmes Schreiberlebnis.',
        ),
        _buildFeatureItem(
          icon: Icons.format_size,
          title: 'Stufenlose Schriftgröße',
          description: 'Stelle die Editor-Schriftgröße zwischen 12 pt und 22 pt ein – ideal für ergonomisches Schreiben auf Smartphones, Tablets und Monitoren.',
        ),
        _buildFeatureItem(
          icon: Icons.dark_mode_outlined,
          title: 'Flexibler Dark Mode',
          description: 'Wähle zwischen Hell, Dunkel oder der automatischen Anpassung an das Betriebssystem deines Geräts.',
        ),
      ],
    );
  }

  _HelpSectionData _getShortcutsSection() {
    return _HelpSectionData(
      category: 'Shortcuts',
      title: '8. Tastaturkürzel (Shortcuts)',
      subtitle: 'Schnellere Bedienung mit Tastatur & Gesten',
      icon: Icons.keyboard_rounded,
      gradientColors: const [Color(0xFF475569), Color(0xFF334155)],
      keywords: ['shortcut', 'tastatur', 'strg', 'cmd', 'rückgängig', 'wiederholen'],
      plainContent: 'Strg+Z für Rückgängig, Strg+Y für Wiederholen.',
      contentWidgets: [
        const SizedBox(height: 8),
        const Text(
          'Besonders auf Tablets mit Tastatur oder Desktop-PCs erleichtern dir diese Tastenkombinationen das Arbeiten enorm:',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        _buildShortcutRow('Strg + Z / ⌘ + Z', 'Rückgängig (Undo) – Letzte Änderung widerrufen'),
        _buildShortcutRow('Strg + Y / ⌘ + ⇧ + Z', 'Wiederholen (Redo) – Widerrufene Änderung wiederherstellen'),
        _buildShortcutRow('Toolbar Buttons', '1-Tipp-Formatierung für Fett, Kursiv, Überschrift & Listen'),
        _buildShortcutRow('Statusleiste tippen', 'Öffnet die detaillierte Dokument-Statistik (Wortzahl, Lesezeit)'),
      ],
    );
  }

  _HelpSectionData _getFaqSection() {
    return _HelpSectionData(
      category: 'FAQ',
      title: '9. Häufige Fragen & Datenschutz (FAQ)',
      subtitle: 'Offline-Garantie, Datenspeicherung & Hilfreiche Tipps',
      icon: Icons.help_center_rounded,
      gradientColors: const [Color(0xFF059669), Color(0xFF047857)],
      keywords: ['faq', 'datenschutz', 'offline', 'fragen', 'sicherheit', 'tipps'],
      plainContent: '100% Offline, keine Serververbindung, deine Dokumente bleiben privat auf deinem Gerät.',
      contentWidgets: [
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'Werden meine Dokumente oder Bilder in die Cloud übertragen?',
          answer:
              'Nein! MarkPDF arbeitet zu 100% lokal und offline auf deinem Gerät. Es gibt keine externe Cloud, keine Benutzerregistrierung und keine Telemetrie-Tracker. Alle Texte und Fotos verbleiben sicher in deinem lokalen App-Speicher.',
        ),
        const SizedBox(height: 10),
        _buildFaqItem(
          question: 'Wie kann ich ein PDF ausdrucken?',
          answer:
              'Tippe im Editor auf das Drei-Punkte-Menü und wähle "Markdown drucken" oder wechsle zum Tab "Vorschau", wo du über den Drucken-Button direkt deinen Netzwerk- oder USB-Drucker ansprechen kannst.',
        ),
        const SizedBox(height: 10),
        _buildFaqItem(
          question: 'Wo werden gespeicherte .md und .pdf Dateien abgelegt?',
          answer:
              'Beim Klick auf Speichern öffnet sich der Standard-Dateidialog deines Betriebssystems (Android Downloads, iOS Dateien, Windows Explorer, macOS Finder), sodass du den Speicherort völlig frei bestimmen kannst.',
        ),
        const SizedBox(height: 10),
        _buildFaqItem(
          question: 'Wie setze ich den Editor auf die Vorlage zurück?',
          answer:
              'Öffne das Menü (Drei Punkte) im Editor und wähle "Muster-Vorlage laden" oder navigiere in die Optionen und tippe auf "Muster-Vorlage wiederherstellen".',
        ),
      ],
    );
  }

  // ==========================================
  // HILFS-WIDGETS FÜR ATTRAKTIVES LAYOUT
  // ==========================================

  Widget _buildStepTile({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
            ),
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.5,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyntaxRow(String code, String explanation) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                width: 0.6,
              ),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              explanation,
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(String keys, String action) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action,
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1D4ED8),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSectionData {
  final String category;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final List<String> keywords;
  final String plainContent;
  final List<Widget> contentWidgets;
  final bool initiallyExpanded;

  _HelpSectionData({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.keywords,
    required this.plainContent,
    required this.contentWidgets,
    this.initiallyExpanded = false,
  });
}
