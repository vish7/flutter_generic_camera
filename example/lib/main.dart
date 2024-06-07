import 'package:flutter/material.dart';
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
                onPressed: () {
                  _flutterGenericCameraPlugin.openCamera({
                    'cameramode': 'photo',
                    'flashmode': 1,
                    'cameraid': '0',
                  });
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
