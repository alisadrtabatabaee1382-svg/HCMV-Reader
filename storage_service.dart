import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/result.dart';

Future<File> _resultsFile() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/results.json');
  if (!await file.exists()) {
    await file.writeAsString(jsonEncode([]));
  }
  return file;
}

Future<void> saveResult(AnalysisResult r) async {
  final file = await _resultsFile();
  final list = jsonDecode(await file.readAsString()) as List;
  list.add(r.toJson());
  await file.writeAsString(jsonEncode(list));
}

Future<void> exportResultsCsv() async {
  final file = await _resultsFile();
  final list = jsonDecode(await file.readAsString()) as List;
  final headers = ['timestamp','index','level','qcOk','testMeanRGB','negMeanRGB'];
  final rows = [headers.join(',')];
  for (final m in list) {
    rows.add('${m['timestamp']},${m['index']},${m['level']},${m['qcOk']},${m['testMeanRGB']},${m['negMeanRGB']}');
  }
  final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final csv = File('${dir.path}/HCMV_results.csv');
  await csv.writeAsString(rows.join('\n'));
}
