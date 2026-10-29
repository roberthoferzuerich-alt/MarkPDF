import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Crop and resize in Isolate test', () async {
    // Erstelle ein 100x100 Testbild
    final testImg = img.Image(width: 100, height: 100);
    img.fill(testImg, color: img.ColorRgb8(255, 0, 0));
    final pngBytes = Uint8List.fromList(img.encodePng(testImg));

    // Testen der Isolate.run Verarbeitung mit Top-Level Funktion
    final params = _TestImageProcessParams(
      rawBytes: pngBytes,
      cropLeft: 0.1,
      cropTop: 0.1,
      cropWidth: 0.8,
      cropHeight: 0.8,
      rotationAngle: 90,
      maxDimension: 50,
      quality: 85,
    );

    final result = await Isolate.run(() => _testIsolateProcessImage(params));
    expect(result, isNotNull);
    expect(result!['width'], equals(50));
    expect(result['bytes'], isA<Uint8List>());
  });
}

class _TestImageProcessParams {
  final Uint8List rawBytes;
  final double cropLeft;
  final double cropTop;
  final double cropWidth;
  final double cropHeight;
  final int rotationAngle;
  final int maxDimension;
  final int quality;

  const _TestImageProcessParams({
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

Map<String, dynamic>? _testIsolateProcessImage(_TestImageProcessParams params) {
  final original = img.decodeImage(params.rawBytes);
  if (original == null) return null;

  img.Image working = original;
  if (params.rotationAngle != 0) {
    working = img.copyRotate(working, angle: params.rotationAngle);
  }

  final int x = (params.cropLeft * working.width).round().clamp(0, working.width - 1);
  final int y = (params.cropTop * working.height).round().clamp(0, working.height - 1);
  final int w = (params.cropWidth * working.width).round().clamp(1, working.width - x);
  final int h = (params.cropHeight * working.height).round().clamp(1, working.height - y);

  img.Image cropped = img.copyCrop(working, x: x, y: y, width: w, height: h);

  if (params.maxDimension > 0 && (cropped.width > params.maxDimension || cropped.height > params.maxDimension)) {
    if (cropped.width >= cropped.height) {
      cropped = img.copyResize(cropped, width: params.maxDimension);
    } else {
      cropped = img.copyResize(cropped, height: params.maxDimension);
    }
  }

  final jpgBytes = Uint8List.fromList(img.encodeJpg(cropped, quality: params.quality));
  return {
    'bytes': jpgBytes,
    'width': cropped.width,
    'height': cropped.height,
  };
}
