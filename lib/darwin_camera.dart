import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class DarwinCamera extends StatefulWidget {
  ///
  /// List of cameras available
  final List<CameraDescription> cameras;

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
    @required this.cameras,
    @required this.resolution,
    @required this.filePath,
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

    file = File(widget.filePath);
    cameraDescription = widget.cameras.first;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Hello deer"),
    );
  }
}
