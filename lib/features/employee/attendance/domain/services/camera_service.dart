import 'package:image_picker/image_picker.dart';

class CameraService {
  CameraService({ImagePicker? picker}) : _pemilih = picker ?? ImagePicker();

  final ImagePicker _pemilih;

  Future<XFile?> takePhoto({required bool cameraFront}) {
    return _pemilih.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: cameraFront
          ? CameraDevice.front
          : CameraDevice.rear,
      imageQuality: 85,
      maxWidth: 1440,
      requestFullMetadata: false,
    );
  }
}
