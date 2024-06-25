import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_generic_camera/config/generic_camera_configuration.dart';
import 'package:flutter_generic_camera/flutter_generic_camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterGenericCameraPlugin = FlutterGenericCamera();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Generic Camera example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (Platform.isIOS) {
                    GenericCameraConfiguration config = GenericCameraConfiguration(
                      captureMode: AssetType.video,
                      canCaptureMultiplePhotos: true,
                      cameraPosition: CameraPosition.front,
                      cameraPhotoFlash: FlashMode.auto,
                      cameraVideoTorch: TorchMode.auto, // In case capture mode video
                    );
                    var capturedData = await _flutterGenericCameraPlugin.openCamera(config);
                    if (capturedData["captured_images"] != null) {
                      debugPrint("Captured Image ${capturedData["captured_images"]}");
                    } else if (capturedData["captured_video"] != null) {
                      debugPrint("Captured Video ${capturedData["captured_video"]}");
                    }
                  }
                },
                child: const Text("Open Camera"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
