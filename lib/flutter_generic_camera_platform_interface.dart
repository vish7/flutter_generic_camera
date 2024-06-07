import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_generic_camera_method_channel.dart';

abstract class FlutterGenericCameraPlatform extends PlatformInterface {
  /// Constructs a FlutterGenericCameraPlatform.
  FlutterGenericCameraPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterGenericCameraPlatform _instance = MethodChannelFlutterGenericCamera();

  /// The default instance of [FlutterGenericCameraPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterGenericCamera].
  static FlutterGenericCameraPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterGenericCameraPlatform] when
  /// they register themselves.
  static set instance(FlutterGenericCameraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>> openCamera([Map<String, Object>? map]) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
