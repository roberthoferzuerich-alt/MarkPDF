import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/pdf_theme_config.dart';

/// Hält die geladenen Schriftarten für das PDF-Dokument bereit.
class _PdfFonts {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font italic;
  final pw.Font boldItalic;
  final pw.Font mono;

  const _PdfFonts({
    required this.regular,
    required this.bold,
    required this.italic,
    required this.boldItalic,
    required this.mono,
  });

  static Future<_PdfFonts> load({bool isSerif = false}) async {
    try {
      if (isSerif) {
        final regular = await PdfGoogleFonts.merriweatherRegular();
        final bold = await PdfGoogleFonts.merriweatherBold();
        final italic = await PdfGoogleFonts.merriweatherItalic();
        final boldItalic = await PdfGoogleFonts.merriweatherBoldItalic();
        final mono = await PdfGoogleFonts.robotoMonoRegular();

        return _PdfFonts(
          regular: regular,
          bold: bold,
          italic: italic,
          boldItalic: boldItalic,
          mono: mono,
        );
      } else {
        final regular = await PdfGoogleFonts.robotoRegular();
        final bold = await PdfGoogleFonts.robotoBold();
        final italic = await PdfGoogleFonts.robotoItalic();
        final boldItalic = await PdfGoogleFonts.robotoBoldItalic();
        final mono = await PdfGoogleFonts.robotoMonoRegular();

        return _PdfFonts(
          regular: regular,
          bold: bold,
          italic: italic,
          boldItalic: boldItalic,
          mono: mono,
        );
      }
    } catch (e) {
      debugPrint('Warnung: Google Fonts konnten nicht geladen werden, Fallback auf Standard-Fonts: $e');
      return _PdfFonts(
        regular: isSerif ? pw.Font.times() : pw.Font.helvetica(),
        bold: isSerif ? pw.Font.timesBold() : pw.Font.helveticaBold(),
        italic: isSerif ? pw.Font.timesItalic() : pw.Font.helveticaOblique(),
        boldItalic: isSerif ? pw.Font.timesBoldItalic() : pw.Font.helveticaBoldOblique(),
        mono: pw.Font.courier(),
      );
    }
  }
}

/// Service zur Konvertierung von Markdown in professionell formatierte PDF-Dokumente.
class MarkdownToPdfService {
  /// Erzeugt die PDF-Bytes aus einem Markdown-String.
  static Future<Uint8List> generatePdfBytes(
    String markdown, {
    String title = 'PDF Dokument',
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    PdfThemeType themeType = PdfThemeType.modernBusiness,
  }) async {
    final pdf = await generatePdfDocument(
      markdown,
      title: title,
      pageFormat: pageFormat,
      themeType: themeType,
    );
    return await pdf.save();
  }

  /// Erzeugt das [pw.Document] aus einem Markdown-String mit ausgewähltem Theme.
  static Future<pw.Document> generatePdfDocument(
    String markdown, {
    String title = 'PDF Dokument',
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    PdfThemeType themeType = PdfThemeType.modernBusiness,
  }) async {
    final themeConfig = PdfThemeConfig.fromType(themeType);
    final fonts = await _PdfFonts.load(isSerif: themeConfig.isSerif);

    final pdf = pw.Document(
      title: title,
      author: 'MarkPDF',
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        italic: fonts.italic,
        boldItalic: fonts.boldItalic,
      ),
    );

    // Markdown AST parsen mit GitHub Flavored Markdown (Tabellen, Strikethrough etc.)
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );
    final lines = markdown.replaceAll('\r\n', '\n').split('\n');
    final nodes = document.parseLines(lines);

    // Bilder vorab asynchron laden (Netzwerk, lokale Dateien, Base64)
    final imageSources = _extractImageSources(nodes);
    final imageCache = await _preloadImages(imageSources);

    // In PDF Widgets umwandeln unter Berücksichtigung des gewählten Themes
    final widgets = _convertNodesToWidgets(nodes, fonts, themeConfig, imageCache);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        header: (context) {
          if (context.pageNumber == 1) return pw.SizedBox();
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.only(bottom: 6),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: themeConfig.dividerColor, width: 0.5),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: fonts.regular,
                fontSize: 8.5,
                color: themeConfig.textMutedColor,
              ),
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 16),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: themeConfig.dividerColor, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'MarkPDF',
                  style: pw.TextStyle(
                    font: fonts.regular,
                    fontSize: 8.5,
                    color: themeConfig.textMutedColor,
                  ),
                ),
                pw.Text(
                  'Seite ${context.pageNumber} von ${context.pagesCount}',
                  style: pw.TextStyle(
                    font: fonts.regular,
                    fontSize: 8.5,
                    color: themeConfig.textMutedColor,
                  ),
                ),
              ],
            ),
          );
        },
        build: (context) => widgets,
      ),
    );

    return pdf;
  }

  /// Extrahiert rekursiv alle Bild-Quellen (src) aus dem Markdown AST.
  static Set<String> _extractImageSources(List<md.Node> nodes) {
    final sources = <String>{};
    void traverse(List<md.Node>? list) {
      if (list == null) return;
      for (final node in list) {
        if (node is md.Element) {
          if (node.tag.toLowerCase() == 'img') {
            final src = node.attributes['src'];
            if (src != null && src.trim().isNotEmpty) {
              sources.add(src.trim());
            }
          }
          traverse(node.children);
        }
      }
    }
    traverse(nodes);
    return sources;
  }

  /// Lädt alle identifizierten Bilder asynchron vor.
  static Future<Map<String, Uint8List>> _preloadImages(Set<String> sources) async {
    final Map<String, Uint8List> cache = {};
    if (sources.isEmpty) return cache;

    await Future.wait(sources.map((src) async {
      try {
        Uint8List? bytes;
        if (src.startsWith('http://') || src.startsWith('https://')) {
          final uri = Uri.tryParse(src);
          if (uri != null) {
            final response = await http.get(uri).timeout(const Duration(seconds: 8));
            if (response.statusCode == 200) {
              bytes = response.bodyBytes;
            }
          }
        } else if (src.startsWith('data:image/')) {
          final commaIndex = src.indexOf(',');
          if (commaIndex != -1) {
            bytes = base64Decode(src.substring(commaIndex + 1));
          }
        } else {
          String path = src;
          if (path.startsWith('file://')) {
            final uri = Uri.tryParse(path);
            if (uri != null) {
              path = uri.toFilePath();
            }
          }
          if (!kIsWeb) {
            final file = File(path);
            if (await file.exists()) {
              bytes = await file.readAsBytes();
            }
          }
        }

        if (bytes != null && bytes.isNotEmpty) {
          cache[src] = bytes;
        }
      } catch (e) {
        debugPrint('Konnte Bild nicht laden ($src): $e');
      }
    }));

    return cache;
  }

  /// Wandelt Markdown AST Nodes in eine Liste von PDF Widgets um.
  static List<pw.Widget> _convertNodesToWidgets(
    List<md.Node> nodes,
    _PdfFonts fonts,
    PdfThemeConfig theme,
    Map<String, Uint8List> imageCache,
  ) {
    final widgets = <pw.Widget>[];

    for (final node in nodes) {
      final widget = _convertBlockNode(node, fonts, theme, imageCache);
      if (widget != null) {
        widgets.add(widget);
      }
    }

    return widgets;
  }

  /// Verarbeitet ein Block-Element (Überschrift, Absatz, Liste, Tabelle etc.).
  static pw.Widget? _convertBlockNode(
    md.Node node,
    _PdfFonts fonts,
    PdfThemeConfig theme,
    Map<String, Uint8List> imageCache,
  ) {
    if (node is! md.Element) {
      if (node is md.Text && node.text.trim().isNotEmpty) {
        final clean = _sanitizeText(node.text);
        if (clean.isNotEmpty) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Text(clean, style: pw.TextStyle(font: fonts.regular, fontSize: 10.5, color: theme.textColor)),
          );
        }
      }
      return null;
    }

    final tag = node.tag.toLowerCase();

    switch (tag) {
      case 'img':
        return _buildImage(node, fonts, theme, imageCache);

      case 'h1':
        return _buildHeading(
          node,
          fonts,
          theme,
          fontSize: 22,
          topPadding: 16,
          bottomPadding: 8,
          color: theme.primaryColor,
          hasBorder: true,
          borderWidth: theme.h1BorderWidth,
        );
      case 'h2':
        return _buildHeading(node, fonts, theme, fontSize: 17, topPadding: 14, bottomPadding: 6, color: theme.secondaryColor);
      case 'h3':
        return _buildHeading(node, fonts, theme, fontSize: 14, topPadding: 12, bottomPadding: 4, color: theme.secondaryColor);
      case 'h4':
        return _buildHeading(node, fonts, theme, fontSize: 12, topPadding: 10, bottomPadding: 4, color: theme.textColor);
      case 'h5':
        return _buildHeading(node, fonts, theme, fontSize: 11, topPadding: 8, bottomPadding: 3, color: theme.textColor);
      case 'h6':
        return _buildHeading(node, fonts, theme, fontSize: 10, topPadding: 8, bottomPadding: 2, color: theme.textMutedColor);

      case 'p':
        final hasImages = node.children?.any((c) => c is md.Element && c.tag.toLowerCase() == 'img') ?? false;
        if (!hasImages) {
          final spans = _buildInlineSpans(
            node.children,
            fonts,
            theme,
            pw.TextStyle(font: fonts.regular, fontSize: 10.5, color: theme.textColor, lineSpacing: 1.5),
          );
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.RichText(text: pw.TextSpan(children: spans)),
          );
        }

        final pWidgets = <pw.Widget>[];
        final currentInline = <md.Node>[];

        void flushInline() {
          if (currentInline.isNotEmpty) {
            final spans = _buildInlineSpans(
              currentInline,
              fonts,
              theme,
              pw.TextStyle(font: fonts.regular, fontSize: 10.5, color: theme.textColor, lineSpacing: 1.5),
            );
            if (spans.isNotEmpty) {
              pWidgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.RichText(text: pw.TextSpan(children: spans)),
                ),
              );
            }
            currentInline.clear();
          }
        }

        for (final child in node.children ?? <md.Node>[]) {
          if (child is md.Element && child.tag.toLowerCase() == 'img') {
            flushInline();
            pWidgets.add(_buildImage(child, fonts, theme, imageCache));
          } else {
            currentInline.add(child);
          }
        }
        flushInline();

        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: pWidgets,
          ),
        );

      case 'ul':
        return _buildList(node, fonts, theme, isOrdered: false);

      case 'ol':
        return _buildList(node, fonts, theme, isOrdered: true);

      case 'blockquote':
        return _buildBlockquote(node, fonts, theme);

      case 'pre':
        return _buildCodeBlock(node, fonts, theme);

      case 'table':
        return _buildTable(node, fonts, theme);

      case 'hr':
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 10),
          child: pw.Divider(color: theme.dividerColor, thickness: 1),
        );

      default:
        if (node.children != null && node.children!.isNotEmpty) {
          final childrenWidgets = <pw.Widget>[];
          for (final child in node.children!) {
            final w = _convertBlockNode(child, fonts, theme, imageCache);
            if (w != null) childrenWidgets.add(w);
          }
          if (childrenWidgets.isNotEmpty) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: childrenWidgets,
            );
          }
        }
        return null;
    }
  }

  /// Erstellt ein Bild-Widget für das PDF inklusive Beschriftung (Alt-Text) und Fehler-Fallback.
  static pw.Widget _buildImage(
    md.Element element,
    _PdfFonts fonts,
    PdfThemeConfig theme,
    Map<String, Uint8List> imageCache,
  ) {
    final src = element.attributes['src']?.trim() ?? '';
    final alt = element.attributes['alt']?.trim();
    final bytes = imageCache[src];

    if (bytes != null && bytes.isNotEmpty) {
      try {
        final image = pw.MemoryImage(bytes);
        return pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.ClipRRect(
                horizontalRadius: 6,
                verticalRadius: 6,
                child: pw.ConstrainedBox(
                  constraints: const pw.BoxConstraints(maxHeight: 280, maxWidth: 480),
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
              ),
              if (alt != null && alt.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(
                    alt,
                    style: pw.TextStyle(
                      font: fonts.italic,
                      fontStyle: pw.FontStyle.italic,
                      fontSize: 9,
                      color: theme.textMutedColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      } catch (e) {
        debugPrint('Fehler beim Rendern des Bildes im PDF: $e');
      }
    }

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: theme.quoteBgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: theme.dividerColor, width: 0.8),
      ),
      child: pw.Text(
        '[Bild: ${alt != null && alt.isNotEmpty ? alt : src}]',
        style: pw.TextStyle(
          font: fonts.italic,
          fontSize: 9,
          color: theme.textMutedColor,
        ),
      ),
    );
  }

  /// Erstellt eine formatierte Überschrift (H1 bis H6).
  static pw.Widget _buildHeading(
    md.Element element,
    _PdfFonts fonts,
    PdfThemeConfig theme, {
    required double fontSize,
    required double topPadding,
    required double bottomPadding,
    required PdfColor color,
    bool hasBorder = false,
    double borderWidth = 1.5,
  }) {
    final spans = _buildInlineSpans(
      element.children,
      fonts,
      theme,
      pw.TextStyle(
        font: fonts.bold,
        fontWeight: pw.FontWeight.bold,
        fontSize: fontSize,
        color: color,
      ),
    );

    final content = pw.RichText(text: pw.TextSpan(children: spans));

    if (hasBorder) {
      return pw.Padding(
        padding: pw.EdgeInsets.only(top: topPadding, bottom: bottomPadding),
        child: pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 5),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: theme.primaryColor, width: borderWidth),
            ),
          ),
          child: content,
        ),
      );
    }

    return pw.Padding(
      padding: pw.EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: content,
    );
  }

  /// Erstellt eine formatierte Liste (geordnet oder ungeordnet).
  static pw.Widget _buildList(
    md.Element listElement,
    _PdfFonts fonts,
    PdfThemeConfig theme, {
    required bool isOrdered,
    int depth = 0,
  }) {
    final items = <pw.Widget>[];
    int index = 1;

    for (final child in listElement.children ?? <md.Node>[]) {
      if (child is md.Element && child.tag == 'li') {
        final itemWidgets = <pw.Widget>[];
        final inlineChildren = <md.Node>[];
        final nestedLists = <md.Element>[];

        for (final liChild in child.children ?? <md.Node>[]) {
          if (liChild is md.Element && (liChild.tag == 'ul' || liChild.tag == 'ol')) {
            nestedLists.add(liChild);
          } else {
            inlineChildren.add(liChild);
          }
        }

        final spans = _buildInlineSpans(
          inlineChildren,
          fonts,
          theme,
          pw.TextStyle(font: fonts.regular, fontSize: 10.5, color: theme.textColor, lineSpacing: 1.3),
        );

        final bulletText = isOrdered ? '$index. ' : '• ';
        final prefixWidth = isOrdered ? 22.0 : 14.0;

        itemWidgets.add(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: prefixWidth,
                child: pw.Text(
                  bulletText,
                  style: pw.TextStyle(
                    font: isOrdered ? fonts.bold : fonts.regular,
                    fontSize: 10.5,
                    color: isOrdered ? theme.primaryColor : theme.textMutedColor,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.RichText(text: pw.TextSpan(children: spans)),
              ),
            ],
          ),
        );

        for (final nested in nestedLists) {
          itemWidgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 14, top: 2),
              child: _buildList(nested, fonts, theme, isOrdered: nested.tag == 'ol', depth: depth + 1),
            ),
          );
        }

        items.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: itemWidgets,
            ),
          ),
        );
        index++;
      }
    }

    return pw.Padding(
      padding: pw.EdgeInsets.only(left: depth * 8.0, bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  /// Erstellt ein Blockquote (Zitat).
  static pw.Widget _buildBlockquote(
    md.Element element,
    _PdfFonts fonts,
    PdfThemeConfig theme,
  ) {
    final spans = _buildInlineSpans(
      element.children,
      fonts,
      theme,
      pw.TextStyle(
        font: fonts.italic,
        fontStyle: pw.FontStyle.italic,
        fontSize: 10,
        color: theme.textColor,
        lineSpacing: 1.4,
      ),
    );

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 6),
      padding: const pw.EdgeInsets.only(left: 12, top: 6, bottom: 6, right: 10),
      decoration: pw.BoxDecoration(
        color: theme.quoteBgColor,
        border: pw.Border(
          left: pw.BorderSide(color: theme.quoteBorderColor, width: 3.5),
        ),
      ),
      child: pw.RichText(text: pw.TextSpan(children: spans)),
    );
  }

  /// Erstellt einen formatierten Quellcode-Block.
  static pw.Widget _buildCodeBlock(
    md.Element element,
    _PdfFonts fonts,
    PdfThemeConfig theme,
  ) {
    String codeContent = element.children?.isNotEmpty == true ? element.children!.first.textContent : element.textContent;
    if (codeContent.endsWith('\n')) {
      codeContent = codeContent.substring(0, codeContent.length - 1);
    }

    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.symmetric(vertical: 6),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: theme.codeBlockBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: theme.codeBlockBorder, width: 0.8),
      ),
      child: pw.Text(
        codeContent,
        style: pw.TextStyle(
          font: fonts.mono,
          fontSize: 9,
          color: theme.codeBlockTextColor,
          lineSpacing: 1.4,
        ),
      ),
    );
  }

  /// Erstellt eine Tabelle mit Theme-Farben.
  static pw.Widget _buildTable(
    md.Element tableElement,
    _PdfFonts fonts,
    PdfThemeConfig theme,
  ) {
    final rows = <pw.TableRow>[];

    void processRow(md.Element tr, {required bool isHeader}) {
      final cells = <pw.Widget>[];

      for (final cellNode in tr.children ?? <md.Node>[]) {
        if (cellNode is md.Element && (cellNode.tag == 'th' || cellNode.tag == 'td')) {
          final spans = _buildInlineSpans(
            cellNode.children,
            fonts,
            theme,
            pw.TextStyle(
              font: isHeader ? fonts.bold : fonts.regular,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 9.5,
              color: isHeader ? theme.tableHeaderTextColor : theme.textColor,
            ),
          );

          final alignAttr = cellNode.attributes['align']?.toLowerCase();
          pw.Alignment cellAlignment = pw.Alignment.centerLeft;
          if (alignAttr == 'center') {
            cellAlignment = pw.Alignment.center;
          } else if (alignAttr == 'right') {
            cellAlignment = pw.Alignment.centerRight;
          }

          cells.add(
            pw.Container(
              alignment: cellAlignment,
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: pw.RichText(text: pw.TextSpan(children: spans)),
            ),
          );
        }
      }

      if (cells.isNotEmpty) {
        rows.add(
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isHeader
                  ? theme.tableHeaderBg
                  : (rows.length.isOdd ? theme.tableAltRowBg : PdfColors.white),
            ),
            children: cells,
          ),
        );
      }
    }

    for (final child in tableElement.children ?? <md.Node>[]) {
      if (child is md.Element) {
        if (child.tag == 'thead' || child.tag == 'tbody') {
          for (final tr in child.children ?? <md.Node>[]) {
            if (tr is md.Element && tr.tag == 'tr') {
              processRow(tr, isHeader: child.tag == 'thead');
            }
          }
        }
      }
    }

    if (rows.isEmpty) return pw.SizedBox();

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Table(
        border: pw.TableBorder.all(color: theme.dividerColor, width: 0.6),
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: rows,
      ),
    );
  }

  /// Bereinigt Emojis, die nicht in Standard-TrueType-Schriften vorkommen.
  static final RegExp _unsupportedGlyphsRegex = RegExp(
    r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}]',
    unicode: true,
  );

  static String _sanitizeText(String text) {
    return text.replaceAll(_unsupportedGlyphsRegex, '');
  }

  /// Verarbeitet Inline-Formatierungen (Fett, Kursiv, Inline-Code, Links, Strikethrough).
  static List<pw.InlineSpan> _buildInlineSpans(
    List<md.Node>? nodes,
    _PdfFonts fonts,
    PdfThemeConfig theme,
    pw.TextStyle baseStyle,
  ) {
    final spans = <pw.InlineSpan>[];
    if (nodes == null || nodes.isEmpty) return spans;

    for (final node in nodes) {
      if (node is md.Text) {
        final cleanText = _sanitizeText(node.text);
        if (cleanText.isNotEmpty) {
          spans.add(pw.TextSpan(text: cleanText, style: baseStyle));
        }
      } else if (node is md.Element) {
        final tag = node.tag.toLowerCase();

        switch (tag) {
          case 'strong':
          case 'b':
            final boldStyle = baseStyle.copyWith(
              font: fonts.bold,
              fontWeight: pw.FontWeight.bold,
            );
            spans.addAll(_buildInlineSpans(node.children, fonts, theme, boldStyle));
            break;

          case 'em':
          case 'i':
            final italicStyle = baseStyle.copyWith(
              font: fonts.italic,
              fontStyle: pw.FontStyle.italic,
            );
            spans.addAll(_buildInlineSpans(node.children, fonts, theme, italicStyle));
            break;

          case 'code':
            final codeText = node.textContent;
            spans.add(
              pw.TextSpan(
                text: ' $codeText ',
                style: pw.TextStyle(
                  font: fonts.mono,
                  fontSize: (baseStyle.fontSize ?? 10.5) * 0.9,
                  color: theme.primaryColor,
                  background: pw.BoxDecoration(
                    color: theme.quoteBgColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  ),
                ),
              ),
            );
            break;

          case 'a':
            final href = node.attributes['href'] ?? '';
            final linkStyle = baseStyle.copyWith(
              color: theme.primaryColor,
              decoration: pw.TextDecoration.underline,
            );
            final linkText = node.textContent;
            final displayText = href.isNotEmpty && !linkText.contains(href)
                ? '$linkText ($href)'
                : linkText;
            spans.add(
              pw.TextSpan(
                text: displayText,
                style: linkStyle,
              ),
            );
            break;

          case 'del':
            final delStyle = baseStyle.copyWith(
              decoration: pw.TextDecoration.lineThrough,
              color: theme.textMutedColor,
            );
            spans.addAll(_buildInlineSpans(node.children, fonts, theme, delStyle));
            break;

          default:
            spans.addAll(_buildInlineSpans(node.children, fonts, theme, baseStyle));
            break;
        }
      }
    }

    return spans;
  }
}
