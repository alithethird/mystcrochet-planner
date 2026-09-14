import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';

class ImageCropperService {
  /// Decodes raw image bytes into a ui.Image
  static Future<ui.Image> decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// Programmatic crop & rotate to 1:1 square at target resolution, returning base64 PNG
  static Future<String> cropAndExportBase64({
    required ui.Image sourceImage,
    required Rect sourceCropRect,
    int rotationQuarterTurns = 0,
    int? targetResolution,
  }) async {
    final res = targetResolution ?? AppConfig.activePhotoResolution;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      Rect.fromLTWH(0, 0, res.toDouble(), res.toDouble()),
    );

    final center = Offset(res / 2, res / 2);
    canvas.save();
    if (rotationQuarterTurns % 4 != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate((rotationQuarterTurns % 4) * (pi / 2));
      canvas.translate(-center.dx, -center.dy);
    }

    final dstRect = Rect.fromLTWH(0, 0, res.toDouble(), res.toDouble());
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;

    canvas.drawImageRect(sourceImage, sourceCropRect, dstRect, paint);
    canvas.restore();

    final picture = recorder.endRecording();
    final renderedImage = await picture.toImage(res, res);
    final byteData =
        await renderedImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to encode cropped image to PNG');
    }

    final bytes = byteData.buffer.asUint8List();
    return base64Encode(bytes);
  }

  /// Calculates an auto-centered 1:1 square bounding box for an image
  static Rect getAutoCenterSquare(int width, int height) {
    final squareSide = min(width, height).toDouble();
    final left = (width - squareSide) / 2;
    final top = (height - squareSide) / 2;
    return Rect.fromLTWH(left, top, squareSide, squareSide);
  }

  /// Picks an image from Camera or Gallery using image_picker
  static Future<Uint8List?> pickImageBytes({required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source);
      if (file == null) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }
}
