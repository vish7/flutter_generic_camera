import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_generic_camera/flutter_generic_camera.dart';

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
  var platform = MethodChannel('flutter_generic_camera');
  String? _imagePath;
  List<ImageModel> imageList = [];
  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onImageCaptured') {
        setState(() {
          _imagePath = call.arguments;
        });
      }else if(call.method == 'onImageCapturedList'){
        final List<dynamic> list = call.arguments;
        final List<ImageModel> images = list.map((item) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(item);
          return ImageModel.fromMap(map);
        }).toList();
        setState(() {
          imageList = images;
          print("list lenth" + imageList.length.toString());
        });
      }
    });
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
              ? Text('No image captured.')
              : Image.file(File(_imagePath!)),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _flutterGenericCameraPlugin.openCamera({
                    'cameramode': 'photo',
                    'flashmode': 1,
                    'cameraid': '0',
                    'isMultiCapture': false,
                  });
                },
                child: const Text("Open Camera"),
              ),
            ),
            imageList.isEmpty ? Text('No image captured.') :
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200, // You can set the desired height
                    child:  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageList.length,
                      itemBuilder: (context, index) {
                        final image = imageList[index];
                        return Container(
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
