import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_generic_camera_platform_interface.dart';

/// An implementation of [FlutterGenericCameraPlatform] that uses method channels.
class MethodChannelFlutterGenericCamera extends FlutterGenericCameraPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_generic_camera');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
