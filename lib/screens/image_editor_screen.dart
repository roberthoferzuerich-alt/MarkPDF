import 'dart:convert';
import 'dart:io';
import 'package:crop_image/crop_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Ergebnis des Zuschneide- und Skalierungsvorgangs.
class EditedImageResult {
  final String path;
  final String alt;
  final int width;
  final int height;
  final int fileSizeBytes;

  const EditedImageResult({
    required this.path,
    required this.alt,
    required this.width,
    required this.height,
    required this.fileSizeBytes,
  });
}

/// Presets für die Bild-Skalierung.
class ImageScalePreset {
  final int dimension; // 0 = Original
  final String label;
  final String tag;

  const ImageScalePreset(this.dimension, this.label, this.tag);
}

const List<ImageScalePreset> kImageScalePresets = [
  ImageScalePreset(200, 'Mini', '200 px'),
  ImageScalePreset(400, 'Klein', '400 px'),
  ImageScalePreset(600, 'Mittel', '600 px'),
  ImageScalePreset(800, 'Standard', '800 px'),
  ImageScalePreset(1200, 'Groß', '1200 px'),
  ImageScalePreset(0, 'Original', '100%'),
];

/// Seitenverhältnis-Presets für das Zuschneiden.
enum AspectRatioOption {
  free(null, 'Frei', Icons.crop_free),
  square(1.0, '1:1', Icons.crop_square),
  classic4_3(4 / 3, '4:3', Icons.crop_landscape),
  widescreen16_9(16 / 9, '16:9', Icons.crop_16_9),
  portrait3_4(3 / 4, '3:4', Icons.crop_portrait);

  final double? ratio;
  final String label;
  final IconData icon;

  const AspectRatioOption(this.ratio, this.label, this.icon);
}

class ImageEditorScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String initialAlt;

  const ImageEditorScreen({
    super.key,
    required this.imageBytes,
    this.initialAlt = 'Foto',
  });

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  late final CropController _cropController;
  late final TextEditingController _altController;

  AspectRatioOption _selectedRatio = AspectRatioOption.free;
  double _targetDimension = 600; // Ausgewogene Standardgröße (z.B. 600 px)
  bool _isOriginalSize = false;
  final int _quality = 85;
  bool _isProcessing = false;

  String _getSizeDescription(int dim) {
    if (dim <= 250) return 'Mini';
    if (dim <= 450) return 'Klein (kompakt)';
    if (dim <= 650) return 'Mittel';
    if (dim <= 900) return 'Web Standard';
    return 'Groß (HD)';
  }

  @override
  void initState() {
    super.initState();
    _cropController = CropController(
      aspectRatio: _selectedRatio.ratio,
      defaultCrop: const Rect.fromLTRB(0.05, 0.05, 0.95, 0.95),
    );
    _altController = TextEditingController(text: widget.initialAlt);
  }

  @override
  void dispose() {
    _cropController.dispose();
    _altController.dispose();
    super.dispose();
  }

  void _setAspectRatio(AspectRatioOption option) {
    setState(() {
      _selectedRatio = option;
      _cropController.aspectRatio = option.ratio;
    });
  }

  Future<void> _processAndSave() async {
    setState(() => _isProcessing = true);

    try {
      final crop = _cropController.crop;
      final rotation = _cropController.rotation;
      int angle = 0;
      switch (rotation) {
        case CropRotation.up:
          angle = 0;
          break;
        case CropRotation.right:
          angle = 90;
          break;
        case CropRotation.down:
          angle = 180;
          break;
        case CropRotation.left:
          angle = 270;
          break;
      }

      final maxDim = _isOriginalSize ? 0 : _targetDimension.round();

      final params = _ImageProcessParams(
        rawBytes: widget.imageBytes,
        cropLeft: crop.left,
        cropTop: crop.top,
        cropWidth: crop.width,
        cropHeight: crop.height,
        rotationAngle: angle,
        maxDimension: maxDim,
        quality: _quality,
      );

      // Im Isolate via Top-Level-Funktion verarbeiten: 100% stabil, isoliert von UI-Objekten
      final processed = await compute(_isolateProcessImage, params);

      if (processed == null) {
        throw Exception('Fehler beim Dekodieren der Bilddaten.');
      }

      final finalBytes = processed['bytes'] as Uint8List;
      final finalWidth = processed['width'] as int;
      final finalHeight = processed['height'] as int;

      // 5. Auf Web als Data-URI, auf nativen Plattformen im Cache-Ordner speichern
      String imagePath;
      if (kIsWeb) {
        imagePath = 'data:image/jpeg;base64,${base64Encode(finalBytes)}';
      } else {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final savedFile = File('${tempDir.path}/web_img_$timestamp.jpg');
        await savedFile.writeAsBytes(finalBytes);
        imagePath = savedFile.path;
      }

      final altText = _altController.text.trim().isNotEmpty ? _altController.text.trim() : 'Bild';

      if (mounted) {
        Navigator.pop(
          context,
          EditedImageResult(
            path: imagePath,
            alt: altText,
            width: finalWidth,
            height: finalHeight,
            fileSizeBytes: finalBytes.length,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Zuschneiden: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Bild zuschneiden & anpassen',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_left),
            tooltip: '90° nach links drehen',
            onPressed: _isProcessing ? null : () => _cropController.rotateLeft(),
          ),
          IconButton(
            icon: const Icon(Icons.rotate_right),
            tooltip: '90° nach rechts drehen',
            onPressed: _isProcessing ? null : () => _cropController.rotateRight(),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check, size: 18),
              label: const Text('Einfügen'),
              onPressed: _isProcessing ? null : _processAndSave,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Zuschneidebereich
          Expanded(
            child: Container(
              color: Colors.black,
              child: CropImage(
                controller: _cropController,
                image: Image.memory(widget.imageBytes),
                paddingSize: 20.0,
                alwaysShowThirdLines: true,
                gridColor: Colors.white70,
                scrimColor: Colors.black.withValues(alpha: 0.65),
              ),
            ),
          ),

          // Unteres Einstellungs-Panel (Material 3 Surface)
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Seitenverhältnis-Auswahl
                    Row(
                      children: [
                        Text(
                          'Zuschnitt:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: AspectRatioOption.values.map((opt) {
                                final isSelected = _selectedRatio == opt;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: ChoiceChip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text(opt.label),
                                    selected: isSelected,
                                    onSelected: _isProcessing ? null : (_) => _setAspectRatio(opt),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 2. Bildgröße-Schieberegler (Slider) & Presets
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.tune,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Bildgröße (Skalieren):',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _isOriginalSize
                                    ? colorScheme.surfaceContainerHighest
                                    : colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _isOriginalSize
                                    ? 'Original (unskaliert)'
                                    : '${_targetDimension.round()} px · ${_getSizeDescription(_targetDimension.round())}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _isOriginalSize
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.photo_size_select_small,
                              size: 18,
                              color: _isOriginalSize ? theme.disabledColor : colorScheme.onSurfaceVariant,
                            ),
                            Expanded(
                              child: Slider(
                                value: _targetDimension.clamp(150, 1600),
                                min: 150,
                                max: 1600,
                                divisions: 29, // Schritte von 50 px
                                label: '${_targetDimension.round()} px',
                                onChanged: _isProcessing
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _isOriginalSize = false;
                                          _targetDimension = val;
                                        });
                                      },
                              ),
                            ),
                            Icon(
                              Icons.photo_size_select_large,
                              size: 22,
                              color: _isOriginalSize ? theme.disabledColor : colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: kImageScalePresets.map((preset) {
                              final isOriginal = preset.dimension == 0;
                              final isSelected = isOriginal
                                  ? _isOriginalSize
                                  : (!_isOriginalSize && (_targetDimension.round() == preset.dimension));

                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text('${preset.label} (${preset.tag})'),
                                  selected: isSelected,
                                  onSelected: _isProcessing
                                      ? null
                                      : (_) {
                                          setState(() {
                                            if (isOriginal) {
                                              _isOriginalSize = true;
                                            } else {
                                              _isOriginalSize = false;
                                              _targetDimension = preset.dimension.toDouble();
                                            }
                                          });
                                        },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 3. Alt-Text (Beschreibung)
                    TextField(
                      controller: _altController,
                      enabled: !_isProcessing,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        labelText: 'Bildunterschrift (Markdown Alt-Text)',
                        hintText: 'z.B. Foto vom Notizbuch',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.subtitles_outlined, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Parameter-Objekt für die Bildverarbeitung im Hintergrund-Isolate.
/// Enthält ausschließlich primitive Datentypen, damit keine Flutter-UI-Objekte
/// oder native Handles über den SendPort übertragen werden müssen.
class _ImageProcessParams {
  final Uint8List rawBytes;
  final double cropLeft;
  final double cropTop;
  final double cropWidth;
  final double cropHeight;
  final int rotationAngle;
  final int maxDimension;
  final int quality;

  const _ImageProcessParams({
    required this.rawBytes,
    required this.cropLeft,
    required this.cropTop,
    required this.cropWidth,
    required this.cropHeight,
    required this.rotationAngle,
    required this.maxDimension,
    required this.quality,
  });
}

/// Top-Level Funktion für `compute`: Läuft in einem separaten Isolate
/// und verarbeitet das Bild rein im CPU-Speicher via package:image.
Map<String, dynamic>? _isolateProcessImage(_ImageProcessParams params) {
  final original = img.decodeImage(params.rawBytes);
  if (original == null) return null;

  // 1. Drehung anwenden
  img.Image working = original;
  if (params.rotationAngle != 0) {
    working = img.copyRotate(working, angle: params.rotationAngle);
  }

  // 2. Zuschneiden (Crop) anhand der normalisierten Koordinaten (0.0 bis 1.0)
  final int x = (params.cropLeft * working.width).round().clamp(0, working.width - 1);
  final int y = (params.cropTop * working.height).round().clamp(0, working.height - 1);
  final int w = (params.cropWidth * working.width).round().clamp(1, working.width - x);
  final int h = (params.cropHeight * working.height).round().clamp(1, working.height - y);

  img.Image cropped = img.copyCrop(working, x: x, y: y, width: w, height: h);

  // 3. Web-Skalierung (Resize)
  final maxDim = params.maxDimension;
  if (maxDim > 0 && (cropped.width > maxDim || cropped.height > maxDim)) {
    if (cropped.width >= cropped.height) {
      cropped = img.copyResize(cropped, width: maxDim, interpolation: img.Interpolation.linear);
    } else {
      cropped = img.copyResize(cropped, height: maxDim, interpolation: img.Interpolation.linear);
    }
  }

  // 4. Als optimiertes JPEG kodieren
  final jpgBytes = Uint8List.fromList(img.encodeJpg(cropped, quality: params.quality));
  return {
    'bytes': jpgBytes,
    'width': cropped.width,
    'height': cropped.height,
  };
}
