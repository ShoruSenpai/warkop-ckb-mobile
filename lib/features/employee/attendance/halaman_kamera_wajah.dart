import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class KameraWajahScreen extends StatefulWidget {
  const KameraWajahScreen({super.key, required this.kameraDepan});
  final bool kameraDepan;
  @override
  State<KameraWajahScreen> createState() => _KameraWajahScreenState();
}

class _KameraWajahScreenState extends State<KameraWajahScreen> {
  CameraController? _controller;
  bool _loading = true, _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    CameraController? camera;
    try {
      final cameras = await availableCameras().timeout(
        const Duration(seconds: 12),
      );
      if (!mounted) return;
      if (cameras.isEmpty)
        throw CameraException(
          'CameraNotFound',
          'Tidak ada webcam yang terdeteksi.',
        );
      final preferred = widget.kameraDepan
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final description =
          cameras.where((c) => c.lensDirection == preferred).firstOrNull ??
          cameras.first;
      camera = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      final current = camera;
      final initialization = current.initialize();
      // A late permission response must not leave the webcam running after closing.
      initialization.then((_) {
        if (!mounted || (_controller != current && !_loading))
          current.dispose();
      }, onError: (_) {});
      await initialization.timeout(const Duration(seconds: 15));
      if (!mounted) {
        await current.dispose();
        return;
      }
      setState(() => _controller = current);
    } catch (e) {
      camera?.dispose();
      if (mounted)
        setState(
          () => _error = e is TimeoutException
              ? 'Kamera belum merespons. Izinkan Kamera pada browser, lalu coba lagi.'
              : 'Webcam tidak dapat dibuka. Izinkan Kamera pada browser dan pastikan tidak digunakan aplikasi lain.',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _take() async {
    final camera = _controller;
    if (_capturing || camera == null || !camera.value.isInitialized) return;
    setState(() => _capturing = true);
    try {
      final photo = await camera.takePicture().timeout(
        const Duration(seconds: 10),
      );
      if (mounted) Navigator.pop(context, photo);
    } catch (_) {
      if (mounted) setState(() => _error = 'Foto gagal diambil. Coba lagi.');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kamera wajah')),
    body: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Posisikan satu wajah di depan webcam, tanpa masker. Pastikan pencahayaan cukup. Mikrofon tidak digunakan.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : _controller == null
                  ? const Icon(Icons.no_photography_outlined, size: 80)
                  : AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _controller == null
                ? OutlinedButton(
                    onPressed: _loading ? null : _open,
                    child: const Text('Coba buka webcam lagi'),
                  )
                : FilledButton.icon(
                    onPressed: _capturing ? null : _take,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _capturing ? 'Mengambil foto…' : 'Ambil foto wajah',
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}
