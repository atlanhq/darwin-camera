# Darwin Camera

Darwin Camera plugin for [Flutter](https://flutter.io).
Supports both iOS and Android.

* Capture image, video and barcode (with scanned barcode text)
* Video player for previewing captured video using [video_player](https://pub.dev/packages/video_player).
* Image compression using [flutter_image_compress](https://pub.dev/packages/flutter_image_compress)
* Video compression using [flutter_video_compress](https://pub.dev/packages/flutter_video_compress)

## Getting Started

In your flutter project add the dependency:

```yml
dependencies:
  ...
  darwin_camera: ^0.0.1
```

For help getting started with Flutter, view the online
[documentation](https://flutter.io/).

## Usage example



Import `darwin_camera.dart`

```dart
import 'package:darwin_camera/core.dart';
```

### Creating a Image capture Widget

This widget captures an image at a provided file path.

```dart
DarwinCamera({
  filePath: 'path-to-file',
  resolution: ResolutionPresets.high,
  shouldCompress: true
})
```

### Example

```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:darwin_camera/darwin_camera.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion = "12";
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   platformVersion = await DarwinCamera.platformVersion;
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Darwin Camera Plugin'),
        ),
        body: DarwinCameraTutorial(),
      ),
    );
  }
}

class DarwinCameraTutorial extends StatelessWidget {
  const DarwinCameraTutorial({Key key}) : super(key: key);

  openCamera(BuildContext context) async {
    PermissionHandler permissionHandler = PermissionHandler();
    await checkForPermissionBasedOnPermissionGroup(permissionHandler, PermissionGroup.camera);

    List<CameraDescription> cameraDescription = await availableCameras();
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DarwinCamera(
          cameraDescription: cameraDescription,
          filePath: "pathForNewFile",
          resolution: ResolutionPreset.high,
        ),
      ),
    );
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("Open Darwin Camera"),
            onPressed: () {
              print("[+] OPEN CAMERA");
              openCamera(context);
            },
          )
        ],
      ),
    );
  }
}

Future<bool> checkForPermissionBasedOnPermissionGroup(
  PermissionHandler permissionHandler,
  PermissionGroup permissionType,
) async {
  ...
  // handle camera permission
}

```

### Directory structure

```
.
├── core.dart
├── darwin_camera.dart
├── darwin_camera_backup.dart
├── utils
│   ├── detector_painter.dart
│   └── scanner_utils.dart
└── video_player.dart
```
