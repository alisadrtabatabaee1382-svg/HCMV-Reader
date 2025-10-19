import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/result.dart';

Future<void> exportResultPdf(AnalysisResult res, String imagePath) async {
  final pdf = pw.Document();
  final date = DateFormat('yyyy-MM-dd – HH:mm').format(res.timestamp);
  final img = File(imagePath).readAsBytesSync();
  final image = pw.MemoryImage(img);
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('HCMV Reader — گزارش نتیجه', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Text('زمان: $date'),
        pw.SizedBox(height: 8),
        pw.Text('شاخص: ${res.index.toStringAsFixed(3)} — سطح: ${res.level.name} — QC: ${res.qcOk ? 'OK' : 'Failed'}'),
        pw.SizedBox(height: 12),
        pw.Text('میانگین RGB (تست): ${res.testMeanRGB}'),
        pw.Text('میانگین RGB (کنترل منفی): ${res.negMeanRGB}'),
        pw.SizedBox(height: 12),
        pw.Text('تصویر:'),
        pw.SizedBox(height: 6),
        pw.Image(image, width: 400),
      ],
    ),
  ));
  final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/HCMV_result_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await pdf.save());
}

Future<void> generateQuickGuidePdf() async {
  final pdf = pw.Document();
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (ctx) => pw.Column(children: [
      pw.Text('راهنمای سریع خوانش با گوشی', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      pw.Bullet(text: 'کارت را روی سطح مات روشن بگذارید.'),
      pw.Bullet(text: 'گوشی را عمود و 10–15 سانتی‌متر بالای کارت نگه دارید.'),
      pw.Bullet(text: 'قاب کامل کارت داخل کادر دوربین باشد.'),
      pw.Bullet(text: 'پس از ثبت، نواحی TEST و NEG را سر جای خود بگذارید و Analyze را بزنید.'),
    ]),
  ));
  final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/HCMV_quick_guide.pdf');
  await file.writeAsBytes(await pdf.save());
}
