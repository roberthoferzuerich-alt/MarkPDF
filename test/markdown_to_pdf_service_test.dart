import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_writer/models/pdf_theme_config.dart';
import 'package:pdf_writer/services/markdown_to_pdf_service.dart';
import 'package:pdf_writer/widgets/sample_markdown.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MarkdownToPdfService Tests', () {
    test('generiert gültige PDF-Bytes aus einfachem Text mit Umlauten', () async {
      const markdown = '# Test Dokument\\nDeutsche Umlaute: Ä, Ö, Ü, ä, ö, ü, ß und Euro €';
      final bytes = await MarkdownToPdfService.generatePdfBytes(markdown, title: 'Umlaut-Test');

      expect(bytes, isNotEmpty);
      final header = String.fromCharCodes(bytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('generiert gültige PDF-Bytes für alle 4 Themes', () async {
      for (final theme in PdfThemeConfig.allThemes) {
        final bytes = await MarkdownToPdfService.generatePdfBytes(
          SampleMarkdown.initialDocument,
          title: 'Themetest ${theme.title}',
          themeType: theme.type,
        );

        expect(bytes, isNotEmpty);
        expect(bytes.length, greaterThan(1000));
        final header = String.fromCharCodes(bytes.take(5));
        expect(header, equals('%PDF-'));
      }
    });

    test('generiert gültige PDF-Bytes für Markdown mit Bildern', () async {
      const markdown = '''
# Dokument mit Bild

Hier ist ein Bild:
![Beispiel Bild](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==)

Und ein Bild mit Fallback:
![Offline Bild](https://example.invalid/404.jpg)
''';
      final bytes = await MarkdownToPdfService.generatePdfBytes(markdown, title: 'Bild-Test');

      expect(bytes, isNotEmpty);
      final header = String.fromCharCodes(bytes.take(5));
      expect(header, equals('%PDF-'));
    });
  });
}
