enum AssetType { photo, video }

class CameraPosition {
  static const int back = 1;
  static const int front = 2;
}

class FlashMode {
  static const int off = 0;
  static const int on = 1;
  static const int auto = 2;
}

class TorchMode {
  static const int off = 0;
  static const int on = 1;
  static const int auto = 2;
}

class GenericCameraConfiguration {
  AssetType captureMode;
  bool canCaptureMultiplePhotos;
  int cameraPosition;
  int cameraPhotoFlash;
  int cameraVideoTorch;

  GenericCameraConfiguration({
    this.captureMode = AssetType.photo,
    this.canCaptureMultiplePhotos = false,
    this.cameraPosition = CameraPosition.back,
    this.cameraPhotoFlash = FlashMode.auto,
    this.cameraVideoTorch = TorchMode.auto,
  });

  Map<String, dynamic> toJson() {
    return {
      'captureMode': captureMode.index,
      'canCaptureMultiplePhotos': canCaptureMultiplePhotos,
      'cameraPosition': cameraPosition,
      'cameraPhotoFlash': cameraPhotoFlash,
      'cameraVideoTorch': cameraVideoTorch,
    };
  }
}
