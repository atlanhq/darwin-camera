import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import './core/core.dart';
export './core/core.dart';
export 'package:camera/camera.dart';

class DarwinCamera extends StatefulWidget {
  //
  /// Flag to enable/disable image compression.
  final bool enableCompression;

  ///
  /// Disables native back functionality provided by iOS using the swipe gestures.
  final bool disableNativeBackFunctionality;

  ///
  /// List of cameras availale in the device.
  ///
  /// How to get the list available cameras?
  /// `List<CameraDescription> cameraDescription = await availableCameras();`
  final List<CameraDescription> cameraDescription;

  ///
  /// Path where the image file will be saved.
  final String filePath;

  ///
  /// Resolution of the image captured
  /// Possible values:
  /// 1. ResolutionPreset.high
  /// 2. ResolutionPreset.medium
  /// 3. ResolutionPreset.low
  final ResolutionPreset resolution;

  ///
  /// Open front camera instead of back camera on launch.
  final bool defaultToFrontFacing;

  ///
  /// Decides the quality of final image captured.
  /// Possible values `0 - 100`
  final int quality;

  DarwinCamera({
    Key key,
    @required this.cameraDescription,
    @required this.filePath,
    this.resolution = ResolutionPreset.high,
    this.enableCompression = false,
    this.disableNativeBackFunctionality = false,
    this.defaultToFrontFacing = false,
    this.quality = 90,
  })  : assert(cameraDescription != null),
        assert(filePath != null),
        assert(quality >= 0 && quality <= 100),
        super(key: key);

  _DarwinCameraState createState() => _DarwinCameraState();
}

class _DarwinCameraState extends State<DarwinCamera>
    with TickerProviderStateMixin {
  ///
  CameraState cameraState;

  ///
  CameraController cameraController;
  CameraDescription cameraDescription;

  ///
  int cameraIndex;

  ///
  File file;

  @override
  void initState() {
    super.initState();
    initVariables();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  ///
  initVariables() {
    cameraState = CameraState.NOT_CAPTURING;
    file = File(widget.filePath);

    ///
    int defaultCameraIndex = widget.defaultToFrontFacing ? 1 : 0;
    selectCamera(defaultCameraIndex, reInitialize: false);
  }

  selectCamera(int index, {bool reInitialize}) {
    cameraIndex = index;
    cameraDescription = widget.cameraDescription[cameraIndex];
    cameraController = CameraController(cameraDescription, widget.resolution);
    if (reInitialize) {
      initCamera();
    }
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

  captureImage() async {
    // print("[+] CAPTURE IMAGE");

    setCameraState(CameraState.CAPTURING);

    ///
    try {
      String savedFilePath;
      savedFilePath = await DarwinCameraHelper.captureImage(
        cameraController,
        widget.filePath,
        enableCompression: widget.enableCompression,
      );
      file = File(savedFilePath);
      setCameraState(CameraState.CAPTURED);
    } catch (e) {
      print(e);
      setCameraState(CameraState.NOT_CAPTURING);
    }
  }

  setCameraState(CameraState newState) {
    ///
    setState(() {
      cameraState = newState;
    });
  }

  toggleCamera() {
    // print("[+] TOGGLE CAMERA");
    int nextCameraIndex;
    if (cameraIndex == 0) {
      nextCameraIndex = 1;
    } else {
      nextCameraIndex = 0;
    }
    setState(() {
      selectCamera(nextCameraIndex, reInitialize: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isCameraInitialized = cameraController.value.isInitialized;
    bool areMultipleCamerasAvailable = widget.cameraDescription.length > 1;
    // print("REBUILD CAMERA STREAM");
    if (isCameraInitialized) {
      return Stack(
        children: <Widget>[
          getRenderCameraStreamWidget(
            showCameraToggle: areMultipleCamerasAvailable,
          ),

          ///
          /// !important We show captured image on the top of camera preview stream.
          /// Else it will throw file path not found error.
          Align(
            alignment: Alignment.topCenter,
            child: Visibility(
              visible: cameraState == CameraState.CAPTURED,
              child: getCapturedImageWidget(),
            ),
          )
        ],
      );
    } else {
      return LoaderOverlay(
        visible: true,
      );
    }
  }

  Widget getRenderCameraStreamWidget({
    bool showCameraToggle,
  }) {
    return RenderCameraStream(
      key: ValueKey("CameraStream"),
      cameraController: cameraController,
      showHeader: true,
      disableNativeBackFunctionality: widget.disableNativeBackFunctionality,
      onBackPress: () {
        Navigator.pop(context);
      },
      showFooter: true,
      leftFooterButton: CancelButton(
        onTap: null,
        opacity: 0,
      ),
      centerFooterButton: CaptureButton(
        key: ValueKey("CaptureButton"),
        buttonPosition: captureButtonPosition,
        buttonSize: captureButtonSize,
        onTap: captureImage,
      ),
      rightFooterButton: ToggleCameraButton(
        key: ValueKey("CameraToggleButton"),
        onTap: toggleCamera,
        opacity: showCameraToggle ? 1.0 : 0.0,
      ),
    );
  }

  Widget getCapturedImageWidget() {
    // print(file.path);
    // print(file.path);
    // print(file.path);
    // print(file.path);
    return RenderCapturedImage(
      key: ValueKey("RenderCapturedImageWidget"),
      file: file,
      leftFooterButton: CancelButton(
        key: ValueKey("CapturedImageCancelButton"),
        opacity: 1,
        onTap: () {
          setCameraState(CameraState.NOT_CAPTURING);
        },
      ),
      centerFooterButton: ConfirmButton(
        key: ValueKey("ConfirmImageButton"),
        onTap: () {
          DarwinCameraHelper.returnResult(context, file: file);
        },
      ),
      rightFooterButton: CancelButton(
        onTap: null,
        opacity: 0,
      ),
    );
  }
}
