import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/employee/attendance/halaman_kamera_wajah.dart';

class LayananKamera {
  LayananKamera({ImagePicker? pemilih}) : _pemilih = pemilih ?? ImagePicker();

  final ImagePicker _pemilih;

  Future<XFile?> ambilFoto({
    required bool kameraDepan,
    required BuildContext context,
  }) {
    if (kIsWeb) {
      return Navigator.of(context).push<XFile>(
        MaterialPageRoute(
          builder: (_) => KameraWajahScreen(kameraDepan: kameraDepan),
        ),
      );
    }
    return _pemilih.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: kameraDepan
          ? CameraDevice.front
          : CameraDevice.rear,
      imageQuality: 85,
      maxWidth: 1440,
      requestFullMetadata: false,
    );
  }
}
