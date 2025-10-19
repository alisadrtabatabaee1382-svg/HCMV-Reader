import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/result.dart';
import '../../services/report_service.dart';
import '../../services/storage_service.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult result;
  final String imagePath;
  const ResultScreen({super.key, required this.result, required this.imagePath});

  Color _colorForLevel(ResultLevel lvl) {
    switch (lvl) {
      case ResultLevel.negative: return Colors.green;
      case ResultLevel.low: return Colors.yellow.shade700;
      case ResultLevel.medium: return Colors.orange;
      case ResultLevel.high: return Colors.red;
    }
  }

  String _label(ResultLevel lvl) {
    switch (lvl) {
      case ResultLevel.negative: return 'منفی';
      case ResultLevel.low: return 'کم';
      case ResultLevel.medium: return 'متوسط';
      case ResultLevel.high: return 'زیاد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نتیجه')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Text(_label(result.level), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _colorForLevel(result.level))),
                const SizedBox(height: 12),
                Text('شاخص: ${result.index.toStringAsFixed(3)}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('کنترل کیفیت: ${result.qcOk ? 'معتبر' : 'نامعتبر'}', style: TextStyle(fontSize: 16, color: result.qcOk ? Colors.green : Colors.red)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('جزئیات', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('میانگین RGB (تست): ${result.testMeanRGB}'),
                Text('میانگین RGB (کنترل منفی): ${result.negMeanRGB}'),
              ]),
            ),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () async {
                await exportResultPdf(result, imagePath);
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('گزارش PDF'),
            )),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(
              onPressed: () async {
                await exportResultsCsv();
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('خروجی CSV'),
            )),
          ]),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.home),
            label: const Text('تست جدید'),
          ),
        ]),
      ),
    );
  }
}
