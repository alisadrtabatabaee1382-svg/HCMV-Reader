import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'roi_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _ready = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    var camStatus = await Permission.camera.request();
    if (!camStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اجازه دسترسی به دوربین لازم است.')));
      }
      return;
    }
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;
    _controller = CameraController(_cameras!.first, ResolutionPreset.high, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    await _controller!.initialize();
    try {
      await _controller!.setFocusMode(FocusMode.locked);
      await _controller!.setExposureMode(ExposureMode.locked);
      await _controller!.setFlashMode(FlashMode.off);
      await _controller!.setExposureOffset(0);
    } catch (_) {}
    if (mounted) setState(() => _ready = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خوانش HCMV — ثبت تصویر')),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : Stack(alignment: Alignment.center, children: [
              CameraPreview(_controller!),
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AspectRatio(
                    aspectRatio: 3/4,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('کارت آزمون را کامل داخل قاب قرار دهید', style: TextStyle(color: Colors.white70))),
                    ),
                  ),
                ),
              ),
            ]),
      floatingActionButton: _ready ? FloatingActionButton.extended(
        onPressed: _busy ? null : _onCapture,
        icon: const Icon(Icons.camera_alt),
        label: const Text('ثبت'),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _onCapture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _busy = true);
    final file = await _controller!.takePicture();
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RoiScreen(imagePath: file.path)));
  }
}
