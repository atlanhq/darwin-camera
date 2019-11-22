import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:darwin_camera/darwin_camera.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
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

class DarwinCameraTutorial extends StatefulWidget {
  const DarwinCameraTutorial({Key key}) : super(key: key);

  @override
  _DarwinCameraTutorialState createState() => _DarwinCameraTutorialState();
}

class _DarwinCameraTutorialState extends State<DarwinCameraTutorial> {
  File imageFile;
  bool isImageCaptured;

  @override
  void initState() {
    super.initState();

    isImageCaptured = false;
  }

  openCamera(BuildContext context) async {
    PermissionHandler permissionHandler = PermissionHandler();

    await checkForPermissionBasedOnPermissionGroup(
      permissionHandler,
      PermissionGroup.camera,
    );

    ///
    String filePath = await FileUtils.getDefaultFilePath();
    String uuid = DateTime.now().millisecondsSinceEpoch.toString();

    ///
    filePath = '$filePath/$uuid.png';

    List<CameraDescription> cameraDescription = await availableCameras();

    ////
    DarwinCameraResult result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DarwinCamera(
          cameraDescription: cameraDescription,
          filePath: filePath,
          resolution: ResolutionPreset.high,
          defaultToFrontFacing: true,
          quality: 90,
        ),
      ),
    );

    ///
    ///
    if (result != null && result.isFileAvailable) {
      setState(() {
        isImageCaptured = true;
        imageFile = result.file;
      });
      print(result.file);
      print(result.file.path);
    }

    ///
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 40.0,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ButtonWithImage(
              key: ValueKey("OpenDarwinCameraButton"),
              title: "Open Darwin Camera",
              iconData: Icons.camera_alt,
              onTap: () {
                print("[+] OPEN CAMERA");
                openCamera(context);
              },
            ),
          ),
          if (isImageCaptured)
            Container(
              margin: padding_a_xs,
              padding: padding_a_xxs,
              decoration: BoxDecoration(
                color: DarwinPrimaryLight,
                borderRadius: BorderRadius.circular(grid_spacer * 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(grid_spacer),
                child: Image.file(
                  imageFile,
                  key: ValueKey("CapturedImagePreview"),
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.center,
                  height: 300,
                ),
              ),
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
  ///
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

class FileUtils {
  static Future<String> getDefaultFilePath() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String mediaDirectory = appDocDir.path + "/media";
      Directory(mediaDirectory).create(recursive: true);
      return mediaDirectory;
    } catch (error, stacktrace) {
      print('could not create folder for media assets');
      print(error);
      print(stacktrace);
      return null;
    }
  }
}

class ButtonWithImage extends StatelessWidget {
  final Key key;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final Icon icon;
  final IconData iconData;
  final String title;

  ButtonWithImage({
    this.key,
    @required this.onTap,
    this.padding,
    this.icon,
    this.iconData,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DarwinPrimaryLight,
        borderRadius: BorderRadius.circular(grid_spacer * 2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Container(
            margin: margin_a_s,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  iconData,
                  color: DarwinPrimary,
                  size: grid_spacer * 5,
                ),
                SizedBox(
                  width: grid_spacer * 1.5,
                ),
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.display1.copyWith(
                        color: DarwinPrimary,
                        height: 1.2,
                        fontSize: 20,
                      ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
