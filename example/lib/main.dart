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
  String _platformVersion = '12';

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
            child: QuestionButton(
              key: ValueKey("OpenDarwinCameraButton"),
              title: "Open Darwin Camera",
              onTap: () {
                print("[+] OPEN CAMERA");
                openCamera(context);
              },
            ),
          ),
          if (isImageCaptured)
            Image.file(
              imageFile,
              key: ValueKey("CapturedImagePreview"),
              fit: BoxFit.fitHeight,
              width: double.infinity,
              alignment: Alignment.center,
              height: 300,
            ),
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

class QuestionButton extends StatelessWidget {
  final Key key;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final Icon icon;
  final IconData iconData;
  final String title;

  QuestionButton({
    this.key,
    @required this.onTap,
    this.padding,
    this.icon,
    this.iconData,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    double width = double.infinity; // ResponsiveUtils.getDeviceWidth(context);
    bool isDeviceSmall = true; //ResponsiveUtils.isDeviceXtraSmall(width);
    bool isDeviceTablet = false; //ResponsiveUtils.isDeviceTablet(width);
    EdgeInsets _padding = (padding) ?? (isDeviceSmall)
        ? (EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 56))
        : (isDeviceTablet)
            ? (EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 9))
            : (EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 16.2));
    IconData _iconData = (iconData) ?? DarwinFont.emoji_happy;
    Icon _icon = (icon) ??
        Icon(
          _iconData,
          color: DarwinPrimary,
          size: (isDeviceTablet) ? grid_spacer * 7 : grid_spacer * 7,
        );
    String _title = (title) ?? 'Tap for\naction';

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
              children: <Widget>[
                Padding(
                  padding: _padding,
                ),
                // _icon,
                SizedBox(
                  width:
                      (isDeviceTablet) ? grid_spacer * 2.5 : grid_spacer * 1.5,
                ),
                Text(
                  _title.toUpperCase(),
                  style: (isDeviceTablet)
                      ? Theme.of(context).textTheme.display3.copyWith(
                            color: DarwinPrimary,
                            height: 1.2,
                          )
                      : Theme.of(context).textTheme.display1.copyWith(
                          color: DarwinPrimary, height: 1.2, fontSize: 24),
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
