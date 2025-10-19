enum ResultLevel { negative, low, medium, high }

class AnalysisResult {
  final double index;
  final ResultLevel level;
  final bool qcOk;
  final String testMeanRGB;
  final String negMeanRGB;
  final DateTime timestamp;

  AnalysisResult({
    required this.index,
    required this.level,
    required this.qcOk,
    required this.testMeanRGB,
    required this.negMeanRGB,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'index': index,
    'level': level.name,
    'qcOk': qcOk,
    'testMeanRGB': testMeanRGB,
    'negMeanRGB': negMeanRGB,
    'timestamp': timestamp.toIso8601String(),
  };
}
