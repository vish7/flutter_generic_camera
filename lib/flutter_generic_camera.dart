import 'flutter_generic_camera_platform_interface.dart';

class FlutterGenericCamera {
  Future<Map<String, dynamic>> openCamera() {
    return FlutterGenericCameraPlatform.instance.openCamera();
  }
}
