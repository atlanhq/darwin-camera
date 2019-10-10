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
  // PermissionGroup permissionType = PermissionGroup.camera;
  PermissionStatus permission;
  permission = await permissionHandler.checkPermissionStatus(permissionType);
  if (permission == PermissionStatus.granted) {
    // takeImageFromCameraAndSave();
    return true;
  }
  var status = await permissionHandler.requestPermissions([permissionType]);
  permission = status[permissionType];

  if (permission == PermissionStatus.granted) {
    // takeImageFromCameraAndSave();
    return true;
  } else {
    ///
    /// ASK USER TO GO TO SETTINGS TO GIVE PERMISSION;

    return false;
  }
}
