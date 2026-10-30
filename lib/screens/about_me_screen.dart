import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/file_service.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  Uint8List? _avatarBytes;
  String? _avatarPath;

  static const String _developerName = 'Robert Hofer';
  static const String _developerLocation = 'Zürich, Schweiz';
  static const String _developerEmail = 'robert.hofer.zuerich@bluewin.ch';

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar();
  }

  Future<void> _loadSavedAvatar() async {
    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/robert_hofer_avatar.jpg');
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (mounted && bytes.isNotEmpty) {
            setState(() {
              _avatarBytes = bytes;
              _avatarPath = file.path;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Hinweis beim Laden des gespeicherten Profilbilds: $e');
    }
  }

  Future<void> _persistAvatar(Uint8List bytes, {String? sourcePath}) async {
    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/robert_hofer_avatar.jpg');
        await file.writeAsBytes(bytes);
        if (mounted) {
          setState(() {
            _avatarBytes = bytes;
            _avatarPath = file.path;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _avatarBytes = bytes;
            _avatarPath = sourcePath;
          });
        }
      }
    } catch (e) {
      debugPrint('Fehler beim persistenten Speichern des Profilbilds: $e');
      if (mounted) {
        setState(() {
          _avatarBytes = bytes;
          _avatarPath = sourcePath;
        });
      }
    }
  }

  Future<void> _deleteAvatar() async {
    try {
      if (!kIsWeb && _avatarPath != null) {
        final file = File(_avatarPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Fehler beim Löschen des Profilbilds: $e');
    }
    if (mounted) {
      setState(() {
        _avatarBytes = null;
        _avatarPath = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilbild wurde zurückgesetzt.')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final bytes = await FileService.pickImageBytes(source: ImageSource.gallery);
      if (bytes != null && bytes.isNotEmpty) {
        await _persistAvatar(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profilbild erfolgreich aus der Galerie importiert!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Auswählen des Bildes: $e')),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final bytes = await FileService.pickImageBytes(source: ImageSource.camera);
      if (bytes != null && bytes.isNotEmpty) {
        await _persistAvatar(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kamerafoto erfolgreich als Profilbild übernommen!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler bei der Kameraaufnahme: $e')),
        );
      }
    }
  }

  Future<void> _pickFromFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );
      if (files.isNotEmpty) {
        final picked = files.first;
        final bytes = await picked.xFile.readAsBytes();
        if (bytes.isNotEmpty) {
          await _persistAvatar(bytes, sourcePath: picked.path);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bild-Datei erfolgreich importiert!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Datei-Import: $e')),
        );
      }
    }
  }

  void _showImageImportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add_a_photo, color: colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profilbild importieren',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Foto für Entwickler-Profil von $_developerName',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Colors.blue),
                  ),
                  title: const Text('Aus Galerie wählen', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Vorhandenes Bild aus Smartphone-Galerie laden'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromGallery();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: Colors.teal),
                  ),
                  title: const Text('Foto aufnehmen', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Neues Foto mit der Gerätekamera machen'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.file_open_outlined, color: Colors.indigo),
                  ),
                  title: const Text('Bild-Datei auswählen', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('JPG-, PNG- oder WebP-Datei vom Gerätespeicher'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromFile();
                  },
                ),
                if (_avatarBytes != null) ...[
                  const Divider(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    title: const Text('Profilbild entfernen', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                    subtitle: const Text('Bild löschen und auf Standard-Initialen zurücksetzen'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _deleteAvatar();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyToClipboard(String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(successMessage)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Über mich & MarkPDF',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: 'Profilbild importieren',
            onPressed: () => _showImageImportBottomSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Entwickler-Hero-Card: Robert Hofer
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [Colors.blue.shade50, Colors.teal.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Avatar mit Foto oder Initialen + Kamera-Badge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 102,
                              height: 102,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.5),
                                child: ClipOval(
                                  child: _avatarBytes != null
                                      ? Image.memory(
                                          _avatarBytes!,
                                          width: 95,
                                          height: 95,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [Color(0xFF1E40AF), Color(0xFF0F766E)],
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'RH',
                                            style: TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            // Kleiner Kamera-Action Button am Avatar
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                shape: const CircleBorder(),
                                elevation: 3,
                                color: colorScheme.primary,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => _showImageImportBottomSheet(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Prominenter Button für den Image Import
                        OutlinedButton.icon(
                          onPressed: () => _showImageImportBottomSheet(context),
                          icon: Icon(
                            _avatarBytes != null ? Icons.edit_outlined : Icons.add_a_photo_outlined,
                            size: 16,
                          ),
                          label: Text(
                            _avatarBytes != null ? 'Profilbild ändern' : 'Bild importieren',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Über den Entwickler',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_developerName · Gründer & Lead Developer',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Wohnort & E-Mail Schnell-Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _copyToClipboard(
                                _developerLocation,
                                'Standort $_developerLocation in die Zwischenablage kopiert!',
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colorScheme.outlineVariant),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                                    const SizedBox(width: 6),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 160),
                                      child: const Text(
                                        '$_developerLocation 🇨🇭',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _copyToClipboard(
                                _developerEmail,
                                'E-Mail $_developerEmail kopiert!',
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colorScheme.outlineVariant),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.email_outlined, size: 16, color: colorScheme.primary),
                                    const SizedBox(width: 6),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 180),
                                      child: Text(
                                        _developerEmail,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hallo! Ich bin $_developerName aus $_developerLocation. Ich entwickle moderne, benutzerfreundliche und datenschutzkonforme Applikationen mit Flutter & Dart. MarkPDF entstand aus dem Anspruch nach einem rasend schnellen, 100% lokalen Markdown-Editor, der strukturierte Gedanken im Handumdrehen in druckreife, perfekt layoutete PDF-Dokumente transformiert – verlässlich, werbefrei und ohne Cloud-Zwang.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildBadge(context, 'Zürich 🇨🇭', Icons.place, Colors.redAccent),
                            _buildBadge(context, 'Lead Dev', Icons.person, Colors.teal),
                            _buildBadge(context, 'Flutter 3.47', Icons.flutter_dash, Colors.blue),
                            _buildBadge(context, 'Dart 3.13', Icons.code, Colors.indigo),
                            _buildBadge(context, '100% Offline', Icons.security, Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Co-Entwickler: Antigravity (Google DeepMind)
                _buildSectionHeader(context, 'KI-Entwicklungspartner & Co-Pilot', Icons.auto_awesome),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1A1B35), const Color(0xFF111827)]
                            : [const Color(0xFFF0F4FF), const Color(0xFFF5F3FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: isDark ? const Color(0xFF4F46E5).withValues(alpha: 0.3) : const Color(0xFF818CF8).withValues(alpha: 0.3),
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.smart_toy_rounded,
                                color: Colors.white,
                                size: 28,
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
                                    runSpacing: 4,
                                    children: [
                                      const Text(
                                        'Antigravity',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Google DeepMind',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4F46E5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'AI Co-Entwickler & Code-Architekt',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'Global · Google DeepMind AI Cloud',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Als autonomer KI-Entwicklungsassistent von Google DeepMind habe ich Seite an Seite mit Robert Hofer das Design und die technische Architektur von MarkPDF geformt. Vom Markdown-Parser, über die 5 individuellen A4-PDF-Themes und den Tabellen-Assistenten bis hin zu den automatisierten Test-Suiten – ein modernes Zusammenspiel aus menschlicher Idee und künstlicher Intelligenz.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.55,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildBadge(context, 'DeepMind AI', Icons.psychology, const Color(0xFF8B5CF6)),
                            _buildBadge(context, 'Pair Programmer', Icons.smart_toy_outlined, const Color(0xFF0284C7)),
                            _buildBadge(context, 'Architecture', Icons.architecture, const Color(0xFFEC4899)),
                            _buildBadge(context, '100% Tests', Icons.verified_outlined, const Color(0xFF10B981)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. MarkPDF Vision
                _buildSectionHeader(context, 'Die Vision von MarkPDF', Icons.lightbulb_outline),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minimalismus trifft Druckqualität',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Markdown ist das eleganteste Format für strukturierte Gedanken. Doch beim Ausdrucken oder Versenden als PDF scheitern herkömmliche Tools oft an Umlauten, Tabellenumbrüchen oder fehlenden Bild-Anpassungen. MarkPDF löst all das direkt auf Ihrem Smartphone oder Tablet – ohne Datenspeicherung in der Cloud.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Highlight-Features
                _buildSectionHeader(context, 'Wichtigste Highlights', Icons.stars_outlined),
                const SizedBox(height: 8),
                _buildFeatureTile(
                  context,
                  icon: Icons.undo,
                  color: Colors.blue,
                  title: 'Vor- & Zurück-Historie (Undo/Redo)',
                  subtitle: 'Tastatur-Shortcuts (Strg+Z/Y) und Toolbar-Buttons für fehlerfreies Bearbeiten.',
                ),
                _buildFeatureTile(
                  context,
                  icon: Icons.table_chart_outlined,
                  color: Colors.teal,
                  title: 'Visueller Tabellen-Assistent',
                  subtitle: 'Vorlagen für Preislisten, Vergleiche & flexible Spalten/Zeilen-Ausrichtung.',
                ),
                _buildFeatureTile(
                  context,
                  icon: Icons.crop_rotate,
                  color: Colors.orange,
                  title: 'Integrierter Foto-Editor & Bild-Import',
                  subtitle: 'Bilder direkt zuschneiden, skalieren oder eigene Profilfotos importieren.',
                ),
                _buildFeatureTile(
                  context,
                  icon: Icons.analytics_outlined,
                  color: Colors.purple,
                  title: 'Echtzeit Dokument-Statistiken',
                  subtitle: 'Wörter, Zeichen, geschätzte Lese- & Redezeit sowie Live-Zeilenzahl.',
                ),
                _buildFeatureTile(
                  context,
                  icon: Icons.picture_as_pdf,
                  color: Colors.red,
                  title: '5 Professionelle PDF-Themes',
                  subtitle: 'Modern Business, Minimalist, Academic, Creative Coral und Sunset Elegance.',
                ),
                const SizedBox(height: 20),

                // 5. Personalien & Kontaktkarte
                _buildSectionHeader(context, 'Personalien & Kontakt', Icons.contact_mail_outlined),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_outline, color: Colors.blue),
                          ),
                          title: const Text('Entwickler'),
                          subtitle: const Text('$_developerName · Zürich, Schweiz 🇨🇭'),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Name kopieren',
                            onPressed: () => _copyToClipboard(_developerName, 'Name "$_developerName" kopiert!'),
                          ),
                        ),
                        const Divider(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.email_outlined, color: Colors.teal),
                          ),
                          title: const Text('E-Mail Kontakt'),
                          subtitle: const Text(_developerEmail),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'E-Mail kopieren',
                            onPressed: () => _copyToClipboard(_developerEmail, 'E-Mail "$_developerEmail" kopiert!'),
                          ),
                        ),
                        const Divider(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF6366F1)),
                          ),
                          title: const Text('Co-Entwickler'),
                          subtitle: const Text('Antigravity (Google DeepMind)'),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline),
                            tooltip: 'Über die KI-Zusammenarbeit',
                            onPressed: () => _copyToClipboard(
                              'Entwickelt von Robert Hofer (Zürich) & Antigravity (Google DeepMind)',
                              'Entwickler-Info kopiert!',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'MarkPDF Studio · Version 1.1.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Entwickelt mit ❤️ in Zürich von Robert Hofer & Antigravity',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildBadge(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
