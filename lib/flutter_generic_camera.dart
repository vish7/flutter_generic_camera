import 'package:flutter_generic_camera/config/generic_camera_configuration.dart';

import 'flutter_generic_camera_platform_interface.dart';

class FlutterGenericCamera {

  Future<Map<String, dynamic>> openCamera([Map<String, Object>? map]) {
    return FlutterGenericCameraPlatform.instance.openCamera(map);

  Future<Map<String, dynamic>> openCamera(GenericCameraConfiguration config) {
    return FlutterGenericCameraPlatform.instance.openCamera(config);

  }
}
