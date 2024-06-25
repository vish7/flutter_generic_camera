import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_generic_camera/config/generic_camera_configuration.dart';

import 'flutter_generic_camera_platform_interface.dart';

/// An implementation of [FlutterGenericCameraPlatform] that uses method channels.
class MethodChannelFlutterGenericCamera extends FlutterGenericCameraPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_generic_camera');

  @override

  Future<Map<String, dynamic>> openCamera([Map<String, Object>? map]) async {
    final results = await methodChannel.invokeMethod('openCamera',map);

  Future<Map<String, dynamic>> openCamera(GenericCameraConfiguration configuration) async {
    final results = await methodChannel.invokeMethod('openCamera', configuration.toJson());
    return Map<String, dynamic>.from(results);
  }
}
