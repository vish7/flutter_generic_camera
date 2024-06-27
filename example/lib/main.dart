import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_generic_camera/config/generic_camera_configuration.dart';
import 'package:flutter_generic_camera/flutter_generic_camera.dart';
import 'package:video_player/video_player.dart';

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
  List<String> imageList = [];
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  String filePath = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: VideoPlayer(_controller),
                                  );
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
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
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
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
                      captureMode: AssetType.photo,
                      canCaptureMultiplePhotos: true,
                      cameraPosition: CameraPosition.front,
                      cameraPhotoFlash: FlashMode.auto,
                      cameraVideoTorch: TorchMode.auto, // In case capture mode video
                    );
                    var capturedData =
                        await _flutterGenericCameraPlugin.openCamera(config);
                    if (capturedData["captured_images"] != null) {
                      debugPrint("Captured Image ${capturedData["captured_images"]}");
                      // imageList.addAll(capturedData["captured_images"]);
                      imageList.clear();
                      imageList.addAll(capturedData["captured_images"].cast<String>());
                      setState(() {
                      });
                    } else if (capturedData["captured_video"] != null) {
                      debugPrint(
                          "Captured Video ${capturedData["captured_video"]}");

                      String pathWithoutProtocol =
                          capturedData["captured_video"]
                              .substring("file:".length);
                      filePath = Uri.decodeFull(pathWithoutProtocol);

                      setState(() {
                        _controller =
                            VideoPlayerController.file(File(filePath));
                        _initializeVideoPlayerFuture = _controller.initialize();
                        _controller.setLooping(true);
                        _controller.setVolume(1.0);
                      });

                      // _controller.pla
                    }
                  }
                },
                child: const Text("Open Camera"),
              ),
            ),
            imageList.isEmpty
                ? (filePath.isNotEmpty ? SizedBox(
                    height: 200,
                    width: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FutureBuilder(
                          future: filePath.isEmpty
                              ? _initializeVideoPlayerFuture =
                                  _controller.initialize()
                              : _initializeVideoPlayerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
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
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ) : const SizedBox()
            )
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
                                  subtitle: Image.file(File(image.toString())),
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
