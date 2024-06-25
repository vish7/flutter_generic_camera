import 'package:flutter_generic_camera/config/generic_camera_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_generic_camera/flutter_generic_camera_platform_interface.dart';
import 'package:flutter_generic_camera/flutter_generic_camera_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterGenericCameraPlatform with MockPlatformInterfaceMixin implements FlutterGenericCameraPlatform {
  @override
  Future<Map<String, dynamic>> openCamera([Map<String, Object>? map]) => Future.value({});
  Future<Map<String, dynamic>> openCamera(GenericCameraConfiguration cameraConfiguration) => Future.value({});
}

void main() {
  final FlutterGenericCameraPlatform initialPlatform = FlutterGenericCameraPlatform.instance;

  test('$MethodChannelFlutterGenericCamera is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterGenericCamera>());
  });
}
