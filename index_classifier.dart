import '../models/result.dart';

ResultLevel classifyIndex(double idx, Map<String, double> thresholds) {
  final t1 = thresholds['t1'] ?? 1.10;
  final t2 = thresholds['t2'] ?? 1.40;
  final t3 = thresholds['t3'] ?? 1.80;
  if (idx < t1) return ResultLevel.negative;
  if (idx < t2) return ResultLevel.low;
  if (idx < t3) return ResultLevel.medium;
  return ResultLevel.high;
}
