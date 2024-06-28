# FlutterGenericCamera
📸 A Flutter plugin that provides a custom camera interface for both Android and iOS, supporting various advanced features including photo capture, video recording, mute, zoom, front and back camera switching, and multiple photo capture.

## Native features

Here's all native features that flutterGenericCamera provides to the flutter side.

| Features                                 | Android | iOS |
| :--------------------------------------- | :-----: | :-: |
| 🔖 Ask permissions                       |   ✅    | ✅  |
| 🎥 Record video                          |   ✅    | ✅  |
| 🔈 Enable/disable audio                  |   ✅    | ✅  |
| 🎞 Take photos                            |   ✅    | ✅  |
| 👁 Zoom                                   |   ✅    | ✅  |
| 📸 Device flash support                  |   ✅    | ✅  |

---

## 📖&nbsp; Installation and usage

### Add the package in your `pubspec.yaml`

```yaml
dependencies:
  flutter_generic_camera: ^0.0.1
  ...
```

### Platform specific setup

- **iOS**

Add these on `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Your own description</string>

<key>NSMicrophoneUsageDescription</key>
<string>To enable microphone access when recording video</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>To enable GPS location access for Exif data</string>
```

- **Android**

Change the minimum SDK version to 21 (or higher) in `android/app/build.gradle`:

```
minSdkVersion 21
```

In order to be able to take pictures or record videos, you may need additional
permissions depending on the Android version and where you want to save them.
Read more about it in the
[official documentation](https://developer.android.com/training/data-storage).

> `WRITE_EXTERNAL_STORAGE` is not included in the plugin starting with version
> 1.4.0.

If you want to record videos with audio, add this permission to your
`AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.example.yourpackage">
  <uses-permission android:name="android.permission.RECORD_AUDIO" />

  <!-- Other declarations -->
</manifest>
```

You may also want to save location of your pictures in exif metadata. In this
case, add below permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
  package="com.example.yourpackage">
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

  <!-- Other declarations -->
</manifest>
```

<details>
<summary>⚠️ Overriding Android dependencies</summary>

Some of the dependencies used by CamerAwesome can be overriden if you have a
conflict. Change these variables to define which version you want to use:

```gradle
buildscript {
  ext.kotlin_version = '1.7.10'
  ext {
    // You can override these variables
    compileSdkVersion = 33
    minSdkVersion = 24 // 21 minimum
    playServicesLocationVersion = "20.0.0"
    exifInterfaceVersion = "1.3.4"
  }
  // ...
}
```

Only change these variables if you are sure of what you are doing.

For example, setting the Play Services Location version might help you when you
have conflicts with other plugins. The below line shows an example of these
conflicts:

```
java.lang.IncompatibleClassChangeError: Found interface com.google.android.gms.location.ActivityRecognitionClient, but class was expected
```

</details>

### Import the package in your Flutter app

```dart
import 'package:flutter_generic_camera/config/generic_camera_configuration.dart';
import 'package:flutter_generic_camera/flutter_generic_camera.dart';
```

---

### How to use it

```dart
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
```
---

## 🐽 Updating Camera configuration

Through state you can access to a `GenericCameraConfiguration` class.

<br>

| Function               | Comment                                                    |
| ---------------------- | ---------------------------------------------------------- |
| `captureMode`              | change capture mode photo or video                                                |
| `canCaptureMultiplePhotos`         | set true for caputre multiple photos                  |
| `cameraPosition`        | change camera positon to front or back |
| `cameraPhotoFlash` | Utilize flash functionalities to improve image quality in low-light conditions.                             |
| `cameraVideoTorch` | Utilize torch functionalities to improve video quality in low-light conditions.                             |

All of these configurations are listenable so your UI can
automatically get updated according to the actual configuration.

