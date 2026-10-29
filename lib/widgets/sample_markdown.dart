class SampleMarkdown {
  static const String initialDocument = '''# MarkPDF

Willkommen bei **MarkPDF**! Diese App kombiniert einen modernen **Markdown-Editor**, einen präzisen **A4-PDF-Konverter** und einen flüssigen **PDF-Reader**.

---

## Wichtigste Highlights
- **Vollständige Unicode-Unterstützung**: Deutsche Umlaute (**ä, ö, ü, ß**) und Währungszeichen (**€**) werden gestochen scharf gerendert.
- **GFM-kompatibel**: Tabellen, Code-Blöcke, Listen und Textstile nach modernem GitHub-Standard.
- **Live-Vorschau**: Schreibe Markdown und sieh das Ergebnis direkt synchron in der Vorschau.

---

## Formatierungsbeispiele

### 1. Textstile
Hier ist normaler Fließtext mit *kursiver Schrift*, **fettem Text** und ~~durchgestrichenen Wörtern~~. Auch `inline_code()` wird hervorgehoben!

> **Hinweis zur Typografie:**
> Durch die dynamische Anbindung von Google Fonts (Roboto & Roboto Mono) bleibt das Schriftbild auf allen Plattformen (Android, iOS, Desktop) konsistent und ansprechend.

### 2. Aufgaben & Listen
- [x] Architektur mit modularer Schichtentrennung
- [x] Markdown AST-Parser via `package:markdown`
- [x] PDF-Renderer mit Mehrseiten-Umbruch (`pw.MultiPage`)
- [ ] Eigene Templates erstellen

#### Geordnete Liste:
1. Markdown verfassen oder Datei öffnen.
2. In den Tab **PDF Vorschau & Export** wechseln.
3. PDF drucken, teilen oder lokal speichern.

---

## Tabellenübersicht

| Modul | Status | Beschreibung | Bewertung |
| :--- | :---: | :--- | :---: |
| **PDF Reader** | Aktiv | Flüssiges Rendering & Volltextsuche | 5 / 5 |
| **Editor** | Aktiv | Live-Vorschau & Werkzeugleiste | 5 / 5 |
| **PDF Converter** | Aktiv | Umwandlung in A4-Vektor-PDF | 5 / 5 |
| **Export/Share** | Aktiv | Direkter Druck- und Systemdialog | 5 / 5 |

---

## Quellcode-Demonstration

```dart
// Beispiel: Markdown zu PDF in Dart
import 'package:pdf_writer/services/markdown_to_pdf_service.dart';

void main() async {
  const markdown = '# Hallo Welt!\\nDeutsche Umlaute: Ä, Ö, Ü, ß';
  final pdfBytes = await MarkdownToPdfService.generatePdfBytes(markdown);
  print('PDF erfolgreich generiert! Größe: \${pdfBytes.length} Bytes');
}
```

---

*Erstellt mit MarkPDF für Flutter • Viel Erfolg beim Dokumentieren!*
''';
}
