import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/color_pipeline.dart';
import '../../services/report_service.dart';
import '../../services/storage_service.dart';
import 'result_screen.dart';

class RoiScreen extends StatefulWidget {
  final String imagePath;
  const RoiScreen({super.key, required this.imagePath});

  @override
  State<RoiScreen> createState() => _RoiScreenState();
}

class _RoiScreenState extends State<RoiScreen> {
  Rect _test = const Rect.fromLTWH(0.35, 0.35, 0.30, 0.20);
  Rect _neg = const Rect.fromLTWH(0.10, 0.75, 0.25, 0.15);
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final img = Image.file(File(widget.imagePath));
    return Scaffold(
      appBar: AppBar(title: const Text('جایگذاری نواحی')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: FittedBox(fit: BoxFit.contain, child: img)),
          Positioned.fill(child: CustomPaint(painter: _OverlayPainter(_test, _neg))),
          _buildDragger('TEST', _test, (r) => setState(() => _test = r), Colors.tealAccent),
          _buildDragger('NEG', _neg, (r) => setState(() => _neg = r), Colors.orangeAccent),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: _busy ? null : () async {
                setState(() => _busy = true);
                final res = await analyzeImage(widget.imagePath, _test, _neg);
                await saveResult(res);
                if (!mounted) return;
                setState(() => _busy = false);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultScreen(result: res, imagePath: widget.imagePath)));
              },
              icon: const Icon(Icons.analytics),
              label: const Text('تحلیل'),
            )),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(
              onPressed: _busy ? null : () async {
                setState(() => _busy = true);
                await generateQuickGuidePdf();
                if (!mounted) return;
                setState(() => _busy = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('راهنمای PDF ساخته شد (Downloads).')));
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('راهنمای PDF'),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _buildDragger(String label, Rect r, ValueChanged<Rect> onChange, Color color) {
    return Positioned.fill(
      child: LayoutBuilder(builder: (ctx, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final left = r.left * w;
        final top = r.top * h;
        final width = max(40, r.width * w);
        final height = max(40, r.height * h);
        return Stack(children: [
          Positioned(
            left: left, top: top, width: width, height: height,
            child: GestureDetector(
              onPanUpdate: (d) {
                final nl = ((left + d.delta.dx) / w).clamp(0.0, 1.0 - r.width);
                final nt = ((top + d.delta.dy) / h).clamp(0.0, 1.0 - r.height);
                onChange(Rect.fromLTWH(nl, nt, r.width, r.height));
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(children: [
                  Positioned(top: 4, left: 6, child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
                  Positioned(right: -12, bottom: -12,
                    child: GestureDetector(
                      onPanUpdate: (d) {
                        final nw = (width + d.delta.dx) / w;
                        final nh = (height + d.delta.dy) / h;
                        onChange(Rect.fromLTWH(r.left, r.top, nw.clamp(0.05, 0.9 - r.left), nh.clamp(0.05, 0.9 - r.top)));
                      },
                      child: Icon(Icons.circle, color: color, size: 24),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect test;
  final Rect neg;
  _OverlayPainter(this.test, this.neg);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawRect(Offset.zero & size, paint);
    final clear = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(RRect.fromRectAndRadius(_rect(size, test), const Radius.circular(10)), clear);
    canvas.drawRRect(RRect.fromRectAndRadius(_rect(size, neg), const Radius.circular(10)), clear);
    final borderTest = Paint()..style = PaintingStyle.stroke..color = Colors.tealAccent..strokeWidth = 2;
    final borderNeg = Paint()..style = PaintingStyle.stroke..color = Colors.orangeAccent..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(_rect(size, test), const Radius.circular(10)), borderTest);
    canvas.drawRRect(RRect.fromRectAndRadius(_rect(size, neg), const Radius.circular(10)), borderNeg);
  }
  Rect _rect(Size s, Rect r) => Rect.fromLTWH(r.left * s.width, r.top * s.height, r.width * s.width, r.height * s.height);
  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) => oldDelegate.test != test || oldDelegate.neg != neg;
}
