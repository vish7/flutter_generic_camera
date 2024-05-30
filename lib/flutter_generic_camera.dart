
import 'flutter_generic_camera_platform_interface.dart';

class FlutterGenericCamera {
  Future<String?> getPlatformVersion() {
    return FlutterGenericCameraPlatform.instance.getPlatformVersion();
  }
}
