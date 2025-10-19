import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

class RoiStats {
  final List<double> meanRgb; // [r,g,b] 0..255
  RoiStats(this.meanRgb);
}

Future<img.Image> loadImage(String path) async {
  final data = await File(path).readAsBytes();
  final decoded = img.decodeImage(data);
  if (decoded == null) {
    throw Exception('Failed to decode image');
  }
  return decoded;
}

// rect: relative (0..1) to input image size
RoiStats computeMeanRGB(img.Image im, Rect rect) {
  final x0 = (rect.left * im.width).clamp(0.0, (im.width - 1).toDouble()).toInt();
  final y0 = (rect.top * im.height).clamp(0.0, (im.height - 1).toDouble()).toInt();
  final w = max(1, (rect.width * im.width).toInt());
  final h = max(1, (rect.height * im.height).toInt());

  double rs = 0, gs = 0, bs = 0;
  int n = 0;
  for (int y = y0; y < min(y0 + h, im.height); y += 2) {
    for (int x = x0; x < min(x0 + w, im.width); x += 2) {
      final p = im.getPixel(x, y);
      rs += img.getRed(p).toDouble();
      gs += img.getGreen(p).toDouble();
      bs += img.getBlue(p).toDouble();
      n++;
    }
  }
  return RoiStats([rs / n, gs / n, bs / n]);
}
