import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:image_picker/image_picker.dart';

class PickedPdfFile {
  final String name;
  final String? path;
  final Uint8List? bytes;

  const PickedPdfFile({
    required this.name,
    this.path,
    this.bytes,
  });
}

class FileService {
  /// Öffnet einen File-Picker zum Auswählen einer lokalen PDF-Datei.
  static Future<PickedPdfFile?> pickPdfFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.xFile.readAsBytes();

        return PickedPdfFile(
          name: file.name,
          path: file.path,
          bytes: bytes,
        );
      }
    } catch (e) {
      debugPrint('Fehler beim Auswählen der PDF-Datei: $e');
    }
    return null;
  }

  /// Öffnet eine bestehende Markdown-Datei (.md, .txt) und gibt ihren Inhalt zurück.
  static Future<String?> pickMarkdownFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown', 'txt'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        return await file.xFile.readAsString();
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Markdown-Datei: $e');
    }
    return null;
  }

  /// Wählt Bild-Bytes aus Galerie oder Kamera (100% kompatibel mit Web, Desktop und Mobile).
  static Future<Uint8List?> pickImageBytes({ImageSource source = ImageSource.gallery}) async {
    // 1. Zuerst ImagePicker versuchen
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        return await picked.readAsBytes();
      }
    } catch (e) {
      debugPrint('ImagePicker nicht verfügbar ($e), nutze FilePicker Fallback...');
    }

    // 2. Zuverlässiger Fallback über FilePicker
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (files.isNotEmpty) {
        return await files.first.xFile.readAsBytes();
      }
    } catch (e) {
      debugPrint('Fehler beim Auswählen des Bildes via FilePicker: $e');
    }
    return null;
  }

  /// Wählt ein Bild aus der Galerie aus und gibt den lokalen Pfad zurück.
  static Future<String?> pickImageFromGallery() async {
    // 1. Zuerst ImagePicker versuchen
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null && picked.path.isNotEmpty) {
        return picked.path;
      }
    } catch (e) {
      debugPrint('ImagePicker für Galerie nicht verfügbar ($e), nutze FilePicker Fallback...');
    }

    // 2. Zuverlässiger Fallback über FilePicker (bereits nativ kompiliert)
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (files.isNotEmpty) {
        final file = files.first;
        if (file.path != null && file.path!.isNotEmpty) {
          return file.path;
        }
        if (!kIsWeb) {
          // Falls Android Scoped Storage / Content-URI nutzt, Bytes in Cache-Datei spiegeln
          final bytes = await file.xFile.readAsBytes();
          final tempDir = await getTemporaryDirectory();
          final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
          final cached = File('${tempDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.$ext');
          await cached.writeAsBytes(bytes);
          return cached.path;
        }
      }
    } catch (e) {
      debugPrint('Fehler beim Auswählen des Bildes via FilePicker: $e');
      rethrow;
    }
    return null;
  }

  /// Nimmt ein neues Foto mit der Kamera auf und gibt den lokalen Pfad zurück.
  static Future<String?> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      return picked?.path;
    } catch (e) {
      debugPrint('Fehler bei der Kameraaufnahme: $e');
      rethrow;
    }
  }

  /// Speichert einen Markdown-String in eine .md Datei.
  static Future<String?> saveMarkdownFile(String content, {String defaultFileName = 'dokument.md'}) async {
    try {
      final bytes = Uint8List.fromList(utf8.encode(content));

      final uri = await FilePicker.saveFile(
        fileName: defaultFileName,
        bytes: bytes,
        mimeType: 'text/markdown',
      );

      if (uri != null && uri.scheme == 'file') {
        return uri.toFilePath();
      }

      // Fallback für Plattformen, falls URI null ist oder manueller Schreibvorgang nötig ist
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final fallbackPath = '${directory.path}${Platform.pathSeparator}$defaultFileName';
        final file = File(fallbackPath);
        await file.writeAsBytes(bytes);
        return fallbackPath;
      }
      return null;
    } catch (e) {
      debugPrint('Fehler beim Speichern der Markdown-Datei: $e');
      return null;
    }
  }

  /// Speichert generierte PDF-Bytes in eine lokale Datei.
  static Future<String?> savePdfFile(Uint8List bytes, {String defaultFileName = 'dokument.pdf'}) async {
    try {
      final uri = await FilePicker.saveFile(
        fileName: defaultFileName,
        bytes: bytes,
        mimeType: 'application/pdf',
      );

      if (uri != null && uri.scheme == 'file') {
        return uri.toFilePath();
      }

      // Fallback falls der Dialog abgebrochen wurde oder Plattform-spezifisch kein Pfad kam
      if (!kIsWeb) {
        final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        final fallbackPath = '${directory.path}${Platform.pathSeparator}$defaultFileName';
        final file = File(fallbackPath);
        await file.writeAsBytes(bytes);
        return fallbackPath;
      }
      return null;
    } catch (e) {
      debugPrint('Fehler beim Speichern der PDF-Datei: $e');
      return null;
    }
  }
}
