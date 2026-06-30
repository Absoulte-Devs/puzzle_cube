import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../models/cube_colors.dart';

/// Turns a photo of a single cube face into the 9 sticker colours.
///
/// The user is expected to frame the face roughly centred in the shot, so we
/// look at the central square of the image, split it into a 3x3 grid and sample
/// a small patch at the centre of each cell. Each sampled colour is snapped to
/// the nearest cube colour via [CubeColors.nearest]. This is deliberately
/// simple (no ML) — it gets close and the user fixes any wrong sticker by hand.
class FaceColorScanner {
  /// Creates a scanner.
  const FaceColorScanner();

  /// Returns 9 cube colours in row-major order (row 0 is the top row of the
  /// face). Throws [FormatException] if [bytes] can't be decoded as an image.
  ///
  /// [region] is the normalised (0..1) rectangle of the upright image to read,
  /// split into the 3x3 grid. The camera flow passes the rectangle that the
  /// on-screen framing square maps to (so what the user framed is what gets
  /// sampled); the gallery flow leaves it null and the central square is used.
  List<Color> classify(Uint8List bytes, {Rect? region}) {
    final raw = img.decodeImage(bytes);
    if (raw == null) {
      throw const FormatException('Could not read the photo.');
    }
    // Apply any EXIF rotation so pixel coordinates match the upright image.
    final image = img.bakeOrientation(raw);

    int rectW, rectH, rectLeft, rectTop;
    if (region != null) {
      rectW = (region.width * image.width).round().clamp(1, image.width);
      rectH = (region.height * image.height).round().clamp(1, image.height);
      rectLeft =
          (region.left * image.width).round().clamp(0, image.width - rectW);
      rectTop =
          (region.top * image.height).round().clamp(0, image.height - rectH);
    } else {
      // Central square avoids most of the background around the cube.
      final side = math.min(image.width, image.height);
      rectW = side;
      rectH = side;
      rectLeft = (image.width - side) ~/ 2;
      rectTop = (image.height - side) ~/ 2;
    }

    final cellW = rectW / 3.0;
    final cellH = rectH / 3.0;
    final patch = (math.min(cellW, cellH) * 0.18).round().clamp(1, 48);

    final colors = <Color>[];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final cx = rectLeft + (cellW * (col + 0.5)).round();
        final cy = rectTop + (cellH * (row + 0.5)).round();
        colors.add(CubeColors.nearest(_averagePatch(image, cx, cy, patch)));
      }
    }
    return colors;
  }

  Color _averagePatch(img.Image image, int cx, int cy, int patch) {
    int r = 0, g = 0, b = 0, count = 0;
    for (int dy = -patch; dy <= patch; dy++) {
      for (int dx = -patch; dx <= patch; dx++) {
        final x = cx + dx;
        final y = cy + dy;
        if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
        final px = image.getPixel(x, y);
        r += px.r.toInt();
        g += px.g.toInt();
        b += px.b.toInt();
        count++;
      }
    }
    if (count == 0) return const Color(0xFF000000);
    return Color.fromARGB(
      255,
      (r / count).round(),
      (g / count).round(),
      (b / count).round(),
    );
  }
}
