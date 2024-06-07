import 'flutter_generic_camera_platform_interface.dart';

class FlutterGenericCamera {
  Future<Map<String, dynamic>> openCamera([Map<String, Object>? map]) {
    return FlutterGenericCameraPlatform.instance.openCamera(map);
  }
}
