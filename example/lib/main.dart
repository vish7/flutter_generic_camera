import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_generic_camera/config/generic_camera_configuration.dart';
import 'package:flutter_generic_camera/flutter_generic_camera.dart';
import 'package:flutter_generic_camera_example/MicrophoneMode.dart';
import 'package:flutter_generic_camera_example/ZoomLevel.dart';
import 'package:video_player/video_player.dart';

import 'ImageModel.dart';

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
  var platform = const MethodChannel('flutter_generic_camera');
  String? _imagePath;
  List<ImageModel> imageList = [];
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onImageCaptured') {
        setState(() {
          _imagePath = call.arguments;
          if (_imagePath.toString().isNotEmpty) {
            if (_imagePath!.endsWith(".mp4")) {
              _controller = VideoPlayerController.file(
                File(_imagePath.toString()),
              );
              _initializeVideoPlayerFuture = _controller.initialize();
              // _controller.play();
              _controller.setLooping(true);
              _controller.setVolume(1.0);
            }
          }
        });
      } else if (call.method == 'onImageCapturedList') {
        final List<dynamic> list = call.arguments;
        final List<ImageModel> images = list.map((item) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(item);
          return ImageModel.fromMap(map);
        }).toList();
        setState(() {
          imageList = images;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            _imagePath == null
                ? const Text('No image captured.')
                : (_imagePath!.endsWith('.mp4')
                    ? SizedBox(
                        height: 200,
                        width: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            FutureBuilder(
                              future: _initializeVideoPlayerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  return AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: VideoPlayer(_controller),
                                  );
                                } else {
                                  return const Center(child: CircularProgressIndicator());
                                }
                              },
                            ),
                            FloatingActionButton(
                              backgroundColor: Colors.black26,
                              onPressed: () {
                                setState(() {
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                  } else {
                                    _controller.play();
                                  }
                                });
                              },
                              child: Icon(
                                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.file(File(_imagePath!))),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (Platform.isIOS) {
                    GenericCameraConfiguration config = GenericCameraConfiguration(
                      captureMode: AssetType.photo,
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
                  } else {
                    GenericCameraConfiguration config = GenericCameraConfiguration(
                      captureMode: AssetType.video,
                      canCaptureMultiplePhotos: true,
                      cameraPosition: CameraPosition.front,
                      cameraPhotoFlash: FlashMode.auto,
                      cameraVideoTorch: TorchMode.auto, // In case capture mode video
                    );
                    _flutterGenericCameraPlugin.openCamera(config);

                    // _flutterGenericCameraPlugin.openCamera({
                    //   'cameramode': CaptureMode.video.name.toString(),
                    //   'flashmode': FlashMode.auto.name.toString(),
                    //   'zoomlevel': ZoomLevel.oneX.name.toString(),
                    //   'cameraid': CameraId.back.name.toString(),
                    //   'isMicrophone': MicrophoneMode.mute.name.toString(),
                    //   'isMultiCapture': true,
                    // });
                  }
                },
                child: const Text("Open Camera"),
              ),
            ),
            imageList.isEmpty
                ? const Text('No image captured.')
                : Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 200, // You can set the desired height
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageList.length,
                            itemBuilder: (context, index) {
                              final image = imageList[index];
                              return SizedBox(
                                width: 150,
                                // You can set the desired width for each item
                                child: ListTile(
                                  title: Text('Image ID: ${image.id}'),
                                  subtitle: Image.file(File(image.path.toString())),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
