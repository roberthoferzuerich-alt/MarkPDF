/// Modell und Berechnungslogik für umfassende Dokument-Statistiken.
class DocumentStatistics {
  final int words;
  final int charactersWithSpaces;
  final int charactersWithoutSpaces;
  final int lines;
  final int paragraphs;
  final int readingTimeMinutes;
  final int speakingTimeMinutes;
  final int headingsCount;
  final int imagesCount;
  final int tablesCount;
  final int codeBlocksCount;

  const DocumentStatistics({
    required this.words,
    required this.charactersWithSpaces,
    required this.charactersWithoutSpaces,
    required this.lines,
    required this.paragraphs,
    required this.readingTimeMinutes,
    required this.speakingTimeMinutes,
    required this.headingsCount,
    required this.imagesCount,
    required this.tablesCount,
    required this.codeBlocksCount,
  });

  /// Analysiert einen Markdown-Text und liefert die berechneten Statistiken.
  factory DocumentStatistics.fromText(String text) {
    if (text.trim().isEmpty) {
      return const DocumentStatistics(
        words: 0,
        charactersWithSpaces: 0,
        charactersWithoutSpaces: 0,
        lines: 0,
        paragraphs: 0,
        readingTimeMinutes: 0,
        speakingTimeMinutes: 0,
        headingsCount: 0,
        imagesCount: 0,
        tablesCount: 0,
        codeBlocksCount: 0,
      );
    }

    final charactersWithSpaces = text.length;
    final charactersWithoutSpaces = text.replaceAll(RegExp(r'\s'), '').length;

    // Zeilen
    final lines = text.split('\n').length;

    // Absätze (zusammenhängende Blöcke, getrennt durch Leerzeilen)
    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .length;

    // Wörter: Markdown-Syntax bereinigen für akkurate Wortzählung
    final words = _countWords(text);

    // Lesezeit: Standardmäßig ca. 200 Wörter pro Minute
    final readingTimeMinutes = words == 0 ? 0 : (words / 200).ceil();

    // Sprechzeit: ca. 130 Wörter pro Minute (Präsentationen, Reden)
    final speakingTimeMinutes = words == 0 ? 0 : (words / 130).ceil();

    // Markdown-Elemente zählen
    final headingsCount = RegExp(r'^#{1,6}\s+.+$', multiLine: true).allMatches(text).length;
    final imagesCount = RegExp(r'!\[.*?\]\(.*?\)').allMatches(text).length;
    final tablesCount = RegExp(r'\|.*?:---.*?\|').allMatches(text).length;
    final codeBlocksCount = RegExp(r'```[\s\S]*?```').allMatches(text).length;

    return DocumentStatistics(
      words: words,
      charactersWithSpaces: charactersWithSpaces,
      charactersWithoutSpaces: charactersWithoutSpaces,
      lines: lines,
      paragraphs: paragraphs,
      readingTimeMinutes: readingTimeMinutes,
      speakingTimeMinutes: speakingTimeMinutes,
      headingsCount: headingsCount,
      imagesCount: imagesCount,
      tablesCount: tablesCount,
      codeBlocksCount: codeBlocksCount,
    );
  }

  static int _countWords(String text) {
    // 1. Code-Blöcke ignorieren
    String cleaned = text.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
    // 2. Links und Bilder bereinigen
    cleaned = cleaned.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1');
    // 3. Tabellentrenner bereinigen
    cleaned = cleaned.replaceAll(RegExp(r'\|'), ' ');
    // 4. Wortgrenzen filtern
    final wordsList = cleaned
        .split(RegExp(r'\s+'))
        .where((w) {
          final stripped = w.replaceAll(RegExp(r'[^a-zA-Z0-9äöüÄÖÜßáéíóú]'), '');
          return stripped.isNotEmpty;
        })
        .toList();
    return wordsList.length;
  }
}
