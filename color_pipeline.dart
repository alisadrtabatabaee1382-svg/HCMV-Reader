import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/result.dart';
import '../utils/image_utils.dart';
import 'index_classifier.dart';

double _srgbToLinear(double c) {
  double v = c / 255.0;
  return v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
}

List<double> _rgbToXyz(double r, double g, double b) {
  final x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375;
  final y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750;
  final z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041;
  return [x, y, z];
}

double _fLab(double t) => t > pow(6/29, 3) ? pow(t, 1/3).toDouble() : (t * (1/3) * pow(29/6, 2) + 4/29);

List<double> _xyzToLab(List<double> xyz, {List<double> white = const [0.95047, 1.00000, 1.08883]}) {
  final xr = xyz[0] / white[0];
  final yr = xyz[1] / white[1];
  final zr = xyz[2] / white[2];
  final fx = _fLab(xr);
  final fy = _fLab(yr);
  final fz = _fLab(zr);
  final L = 116 * fy - 16;
  final a = 500 * (fx - fy);
  final b = 200 * (fy - fz);
  return [L, a, b];
}

double _computeIndex(List<double> testRGB, {List<double>? negRGB}) {
  final rg = (testRGB[0] + testRGB[1]).clamp(1.0, 510.0);
  final ratio = rg / (testRGB[2].clamp(1.0, 255.0));
  final rL = _srgbToLinear(testRGB[0]);
  final rG = _srgbToLinear(testRGB[1]);
  final rB = _srgbToLinear(testRGB[2]);
  final lab = _xyzToLab(_rgbToXyz(rL, rG, rB));
  final a = lab[1];
  final b = lab[2];
  final hue = (atan2(b, a) * 180 / pi + 360) % 360;
  double normRatio = ratio;
  if (negRGB != null) {
    final nr = ((negRGB[0] + negRGB[1]).clamp(1.0, 510.0)) / (negRGB[2].clamp(1.0, 255.0));
    normRatio = ratio / nr;
  }
  final index = 0.8 * normRatio + 0.2 * (hue / 180.0);
  return index;
}

Future<AnalysisResult> analyzeImage(String imagePath, Rect testRectRel, Rect negRectRel) async {
  final im = await loadImage(imagePath);
  final testStats = computeMeanRGB(im, testRectRel);
  final negStats = computeMeanRGB(im, negRectRel);
  final idx = _computeIndex(testStats.meanRgb, negRGB: negStats.meanRgb);
  final thresholds = await _loadThresholds();
  final level = classifyIndex(idx, thresholds);
  final qcOk = _qcBasic(testStats.meanRgb, negStats.meanRgb);
  return AnalysisResult(
    index: idx,
    level: level,
    qcOk: qcOk,
    testMeanRGB: testStats.meanRgb.map((e) => e.toStringAsFixed(1)).join(','),
    negMeanRGB: negStats.meanRgb.map((e) => e.toStringAsFixed(1)).join(','),
    timestamp: DateTime.now(),
  );
}

bool _qcBasic(List<double> t, List<double> n) {
  final tMean = (t[0] + t[1] + t[2]) / 3.0;
  final nMean = (n[0] + n[1] + n[2]) / 3.0;
  return tMean > 10 && tMean < 245 && nMean > 10 && nMean < 245;
}

Future<Map<String, double>> _loadThresholds() async {
  final file = File('assets/config.json');
  final data = json.decode(await file.readAsString());
  final th = data['thresholds'] as Map<String, dynamic>;
  return {'t1': (th['t1'] as num).toDouble(), 't2': (th['t2'] as num).toDouble(), 't3': (th['t3'] as num).toDouble()};
}
