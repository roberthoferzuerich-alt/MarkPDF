import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_writer/models/document_statistics.dart';

void main() {
  group('DocumentStatistics Unit Tests', () {
    test('Empty text returns zeroes', () {
      final stats = DocumentStatistics.fromText('');
      expect(stats.words, equals(0));
      expect(stats.charactersWithSpaces, equals(0));
      expect(stats.charactersWithoutSpaces, equals(0));
      expect(stats.lines, equals(0));
      expect(stats.paragraphs, equals(0));
      expect(stats.readingTimeMinutes, equals(0));
      expect(stats.speakingTimeMinutes, equals(0));
      expect(stats.headingsCount, equals(0));
      expect(stats.imagesCount, equals(0));
      expect(stats.tablesCount, equals(0));
      expect(stats.codeBlocksCount, equals(0));
    });

    test('Accurately counts words, characters, headings, and elements in sample markdown', () {
      const sample = '''
# Hauptüberschrift

Das ist ein deutscher Testabsatz mit Umlauten: Äpfel, Öle, Übermut.

## Untertitel

Hier ist ein zweiter Absatz.

| Spalte 1 | Spalte 2 |
| :--- | ---: |
| Wert A | Wert B |

![Bild](https://example.com/test.jpg)

```dart
void main() {
  print("Hello");
}
```
''';

      final stats = DocumentStatistics.fromText(sample);

      expect(stats.headingsCount, equals(2)); // # Hauptüberschrift & ## Untertitel
      expect(stats.imagesCount, equals(1));
      expect(stats.tablesCount, equals(1));
      expect(stats.codeBlocksCount, equals(1));
      expect(stats.words, greaterThan(15));
      expect(stats.lines, greaterThan(15));
      expect(stats.paragraphs, greaterThanOrEqualTo(3));
      expect(stats.readingTimeMinutes, equals(1));
      expect(stats.speakingTimeMinutes, equals(1));
    });
  });
}
