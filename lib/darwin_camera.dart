import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'core.dart';

class DarwinCamera extends StatefulWidget {
  ///
  /// List of cameras available
  final List<CameraDescription> cameraDescription;

  ///
  /// Resolution of the image
  ///
  /// Possible values
  ///
  /// - `ResolutionPreset.high`
  /// - `ResolutionPreset.medium`
  /// - `ResolutionPreset.low`
  ///
  final ResolutionPreset resolution;

  ///
  /// path where file wil be stored.
  final String filePath;

  final bool enableCompression;

  DarwinCamera({
    Key key,
    @required this.cameraDescription,
    @required this.filePath,
    this.resolution = ResolutionPreset.high,
    this.enableCompression = false,
  }) : super(key: key);

  _DarwinCameraState createState() => _DarwinCameraState();
}

class _DarwinCameraState extends State<DarwinCamera>
    with TickerProviderStateMixin {
  ///
  CameraController cameraController;
  CameraDescription cameraDescription;

  ///
  File file;

  @override
  void initState() {
    super.initState();
    initVariables();
    initCamera();
  }

  ///
  initVariables() {
    file = File(widget.filePath);
    cameraDescription = widget.cameraDescription.first;
    cameraController = CameraController(cameraDescription, widget.resolution);
  }

  ///
  initCamera() {
    cameraController.initialize().then((onValue) {
      ///
      ///
      /// !DANGER: Do not remove this piece of code.
      /// Why?
      /// Removing this code will make the library stuck in loading state.
      /// After `mounting` we call `setState` so that the widget rebuild and
      /// we see a stream of camera instead of loader.
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isCameraInitialized = cameraController.value.isInitialized;

    if (isCameraInitialized) {
      return RenderCameraStream(
        cameraController: cameraController,
        showHeader: true,
        onBackPress: () {
          print("HERE");
        },
      );
    } else {
      return LoaderOverlay(
        visible: true,
      );
    }
  }
}
