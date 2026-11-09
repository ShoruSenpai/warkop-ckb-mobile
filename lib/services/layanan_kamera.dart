import 'package:image_picker/image_picker.dart';

class LayananKamera {
  LayananKamera({ImagePicker? pemilih}) : _pemilih = pemilih ?? ImagePicker();

  final ImagePicker _pemilih;

  Future<XFile?> ambilFoto({required bool kameraDepan}) {
    return _pemilih.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice:
          kameraDepan ? CameraDevice.front : CameraDevice.rear,
      imageQuality: 85,
      maxWidth: 1440,
      requestFullMetadata: false,
    );
  }
}