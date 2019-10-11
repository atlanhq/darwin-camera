import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:darwin_design_system/darwin_design_system.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './utils/detector_painter.dart';
import './utils/scanner_utils.dart';
import './video_player.dart';

enum CameraMode { CAMERA, BARCODE, VIDEO }
enum CameraState { CAPTURING, CAPTURED }
enum CameraResolution { LOW, HIGH, MEDIUM }
enum VideoRecordingState { START, STOP }

/// Custom component for camera
///
class DarwinCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraResolution resolution;
  final String filePath;
  final CameraMode cameraMode;

  ///
  final CameraState initialState;
  final int maxTimeLimit;

  DarwinCamera({
    @required this.cameras,
    @required this.resolution,
    @required this.cameraMode,
    @required this.filePath,
    this.initialState = CameraState.CAPTURING,
    this.maxTimeLimit = 60,
  });

  @override
  _DarwinCameraState createState() => _DarwinCameraState();
}

class _DarwinCameraState extends State<DarwinCamera>
    with TickerProviderStateMixin {
  BarcodeDetector _barcodeDetector = FirebaseVision.instance.barcodeDetector();
  bool isDetecting = false;
  bool resetTimer = false;
  bool isImageCaptured = false;
  bool isFileCompressionDone = false;
  bool showHeader = true;
  bool showLoader = false;
  bool showReverseCamera = true;

  CameraController cameraController;
  CameraDescription cameraDescription;
  CameraMode cameraMode;
  CameraState cameraState;

  Detector currentDetector = Detector.barcode;

  double cameraInnerBorderRadius = grid_spacer * 10;
  double cameraInnerShutterSize = grid_spacer * 8;
  double cameraShutterPosition = grid_spacer;
  double cameraShutterSize = grid_spacer * 10;
  double scale = 1.0;

  dynamic cameraScanResults;
  File file;
  File videoThumbnail;
  int videoMaxTimeLimit;
  int videoTimeInterval;

  Rectangle barcodePainterRectangleSize = Rectangle(width: 320, height: 144);
  ResolutionPreset resolutionPreset;

  String filePath;
  String loaderText = 'Loading, Please wait...';
  String rawBarcodeValue = '';
  Timer countdownTimer;
  VideoRecordingState _videoRecordingState = VideoRecordingState.START;

  ///
  /// Maps our CameraResolution with flutter native ResolutionPreset.
  final Map<CameraResolution, ResolutionPreset> getResolutionPreset = {
    CameraResolution.HIGH: ResolutionPreset.high,
    CameraResolution.MEDIUM: ResolutionPreset.medium,
    CameraResolution.LOW: ResolutionPreset.low,
  };

  final _flutterVideoCompress = FlutterVideoCompress();

  // Linear Gradient for the background
  LinearGradient bgGradient(begin, end) {
    return LinearGradient(
      colors: [
        Colors.black,
        Colors.transparent,
      ],
      begin: begin,
      end: end,
    );
  }

  //=======================================================================
  //
  //  ##  ##     ##  ##  ######  ##    ###    ##      ##  ######  #####
  //  ##  ####   ##  ##    ##    ##   ## ##   ##      ##     ##   ##
  //  ##  ##  ## ##  ##    ##    ##  ##   ##  ##      1##    ##    #####
  //  ##  ##    ###  ##    ##    ##  #######  ##      ##   ##     ##
  //  ##  ##     ##  ##    ##    ##  ##   ##  ######  ##  ######  #####
  //
  //=======================================================================
  @override
  void initState() {
    super.initState();

    filePath = widget.filePath;
    file = File(filePath);

    cameraDescription = widget.cameras[0];
    cameraMode = widget.cameraMode;
    cameraState = widget.initialState;
    resolutionPreset = getResolutionPreset[widget.resolution];

    ///
    cameraController = CameraController(cameraDescription, resolutionPreset);
    videoMaxTimeLimit = widget.maxTimeLimit;
    videoTimeInterval = videoMaxTimeLimit;
    if (cameraMode == CameraMode.BARCODE) {
      _initializeBarcodeCamera();
    } else {
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
  }

  ///
  ///
  ///
  _initializeBarcodeCamera() async {
    await cameraController.initialize();

    ///
    cameraController.startImageStream((CameraImage image) {
      if (isDetecting) return;

      ///
      isDetecting = true;
      ScannerUtils.detect(
        image: image,
        detectInImage: _barcodeDetector.detectInImage,
        imageRotation: cameraDescription.sensorOrientation,
      ).then(
        (dynamic results) {
          if (currentDetector == null) return;
          setState(() {
            cameraScanResults = results;
          });
          //
          final Size imageSize = Size(
            cameraController.value.previewSize.height,
            cameraController.value.previewSize.width,
          );
          if (cameraScanResults.length != 0) {
            cameraController.stopImageStream().then((_) {
              takePicture().then((_) {
                cameraStateController(CameraState.CAPTURED);
              });
            });
            _handleResult(
              barcodes: cameraScanResults,
              data: MediaQuery.of(context),
              imageSize: imageSize,
            );
          }
        },
      ).whenComplete(() => isDetecting = false);
    });
  }

  //======================================================
  //
  //  ####    ##   ####  #####    #####    ####  #####
  //  ##  ##  ##  ##     ##  ##  ##   ##  ##     ##
  //  ##  ##  ##   ###   #####   ##   ##   ###   #####
  //  ##  ##  ##     ##  ##      ##   ##     ##  ##
  //  ####    ##  ####   ##       #####   ####   #####
  //
  //======================================================
  @override
  void dispose() {
    if (countdownTimer != null) {
      countdownTimer.cancel();
    }
    cameraController.dispose().then((_) {
      _barcodeDetector.close();
    });
    currentDetector = null;
    super.dispose();
  }

  // When back is pressed -> go to back screen
  void _onBackPressed() {
    // Result wiht empty file
    DarwinCameraResult result = DarwinCameraResult(file: null);
    Navigator.pop(context, result);
  }

  //=========================================
  //
  //  #####   ##   ##  ##  ##      ####
  //  ##  ##  ##   ##  ##  ##      ##  ##
  //  #####   ##   ##  ##  ##      ##  ##
  //  ##  ##  ##   ##  ##  ##      ##  ##
  //  #####    #####   ##  ######  ####
  //
  //=========================================
  @override
  Widget build(BuildContext context) {
    print("REBUILD CAMERA");
    Size size = MediaQuery.of(context).size;

    ///
    ///
    /// Show loader
    if (!cameraController.value.isInitialized) {
      return Container(
        child: LoaderOverlay(
          visible: true,
        ),
      );
    }

    ///
    ///
    /// Show Camera
    return WillPopScope(
      onWillPop: () async {
        _onBackPressed();
        return false;
      },
      child: Stack(
        children: <Widget>[
          ClipRect(
            child: Container(
              child: Transform.scale(
                scale: cameraController.value.aspectRatio / size.aspectRatio,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: (cameraMode == CameraMode.BARCODE)
                        ? Container()
                        : previewCamera(cameraState),
                  ),
                ),
              ),
            ),
          ),
          (cameraMode == CameraMode.BARCODE)
              ? Container()
              : Visibility(
                  visible: showHeader,
                  child: getHeader(),
                ),
          Visibility(visible: !isImageCaptured, child: getBody()),
          Visibility(visible: isImageCaptured, child: getCaptureResultBody()),
          LoaderOverlay(
            visible: showLoader,
            helperText: loaderText,
          ),
        ],
      ),
    );
  }

  //================================================================================================================
  //
  //   ####    ###    ###    ###  #####  #####      ###          ##   ##  #####    ###    ####    #####  #####
  //  ##      ## ##   ## #  # ##  ##     ##  ##    ## ##         ##   ##  ##      ## ##   ##  ##  ##     ##  ##
  //  ##     ##   ##  ##  ##  ##  #####  #####    ##   ##        #######  #####  ##   ##  ##  ##  #####  #####
  //  ##     #######  ##      ##  ##     ##  ##   #######        ##   ##  ##     #######  ##  ##  ##     ##  ##
  //   ####  ##   ##  ##      ##  #####  ##   ##  ##   ##        ##   ##  #####  ##   ##  ####    #####  ##   ##
  //
  //================================================================================================================
  Widget getHeader() {
    switch (cameraMode) {
      case CameraMode.CAMERA:
      case CameraMode.VIDEO:
      case CameraMode.BARCODE:
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            decoration: BoxDecoration(
              gradient: bgGradient(Alignment.topCenter, Alignment.bottomCenter),
            ),
            padding: padding_x_s + padding_top_s + padding_bottom_xl,
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _onBackPressed();
                    },
                    child: Container(
                      padding: padding_right_s + padding_bottom_s,
                      child: Icon(
                        DarwinFont.cancel,
                        color: DarwinWhite,
                        size: grid_spacer * 2.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;
    }
  }

  //==================================================================================================
  //
  //   ####    ###    ###    ###  #####  #####      ###          #####    #####   ####    ##    ##
  //  ##      ## ##   ## #  # ##  ##     ##  ##    ## ##         ##  ##  ##   ##  ##  ##   ##  ##
  //  ##     ##   ##  ##  ##  ##  #####  #####    ##   ##        #####   ##   ##  ##  ##    ####
  //  ##     #######  ##      ##  ##     ##  ##   #######        ##  ##  ##   ##  ##  ##     ##
  //   ####  ##   ##  ##      ##  #####  ##   ##  ##   ##        #####    #####   ####       ##
  //
  //==================================================================================================
  Widget getBody() {
    Size size = MediaQuery.of(context).size;

    switch (cameraMode) {
      case CameraMode.BARCODE:
        return Align(
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
              CustomPaint(
                foregroundPainter: BGPaint(),
                child: Transform.scale(
                  scale: cameraController.value.aspectRatio / size.aspectRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: cameraController.value.aspectRatio,
                      child: previewCamera(cameraState),
                    ),
                  ),
                ),
              ),
              ClipPath(
                clipper: ClipBarcode(),
                child: Transform.scale(
                  scale: cameraController.value.aspectRatio / size.aspectRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: cameraController.value.aspectRatio,
                      child: previewCamera(cameraState),
                    ),
                  ),
                ),
              ),
              _buildResults(),
              getHeader(),
            ],
          ),
        );
        break;
      case CameraMode.CAMERA:
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              gradient: bgGradient(Alignment.bottomCenter, Alignment.topCenter),
            ),
            padding: padding_x_s + padding_top_xl + padding_bottom_l,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    padding: padding_a_s,
                    child: Opacity(
                      opacity: 0,
                      child: Icon(
                        DarwinFont.cancel,
                        color: DarwinDanger,
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: shutterButton(),
                    onTap: () async {
                      setState(() {
                        cameraShutterSize = grid_spacer * 12;
                        cameraShutterPosition = grid_spacer * 2;
                      });
                      Timer(Duration(milliseconds: 150), () {
                        setState(() {
                          cameraShutterSize = grid_spacer * 10;
                          cameraShutterPosition = grid_spacer;
                        });
                      });
                      await takePicture();
                      cameraStateController(CameraState.CAPTURED);
                    },
                  ),
                  GestureDetector(
                    child: Container(
                      padding: padding_a_s,
                      child: Icon(
                        DarwinFont.refresh,
                        color: DarwinWhite,
                      ),
                    ),
                    onTap: () async {
                      cameraController = await changeController();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        );
        break;
      case CameraMode.VIDEO:
        return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient:
                    bgGradient(Alignment.bottomCenter, Alignment.topCenter),
              ),
              padding: padding_x_s + padding_top_xl + padding_bottom_l,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      width: grid_spacer * 10,
                      padding: padding_y_s,
                      child: Text(
                        '00:${videoTimeInterval.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.display1.copyWith(
                              color: DarwinWhite,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      child: videoRecordingButton(),
                      onTap: () async {
                        setState(() {
                          cameraShutterSize = grid_spacer * 12;
                          cameraShutterPosition = grid_spacer * 3.5;
                          cameraInnerShutterSize = grid_spacer * 5;
                          cameraInnerBorderRadius = grid_spacer;
                        });
                        Timer(Duration(milliseconds: 150), () {
                          setState(() {
                            cameraShutterPosition = (_videoRecordingState ==
                                    VideoRecordingState.START)
                                ? grid_spacer * 2.5
                                : grid_spacer;
                            cameraShutterSize = grid_spacer * 10;
                          });
                        });
                        if (_videoRecordingState == VideoRecordingState.START) {
                          showHeader = false;
                          showReverseCamera = false;
                          Timer(Duration(milliseconds: 200), () {
                            _videoRecordingState = VideoRecordingState.STOP;
                          });
                          startCountdownTimer();
                          await startVideoRecording().then((path) {
                            print('******* File Path ******* --->  $path');
                          });
                        } else {
                          autoStopVideoRecording();
                        }
                      },
                    ),
                    Opacity(
                      opacity: (showReverseCamera) ? 1 : 0,
                      child: GestureDetector(
                        child: Container(
                          width: grid_spacer * 10,
                          padding: padding_y_s,
                          child: Icon(
                            DarwinFont.refresh,
                            color: DarwinWhite,
                          ),
                        ),
                        onTap: () async {
                          (showReverseCamera)
                              ? cameraController = await changeController()
                              : setState(() {});
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ));
        break;
    }
  }

  //===============================================================================================================
  //
  //   ####    ###    ###    ###  #####  #####      ###          #####    #####   ####  ##   ##  ##      ######
  //  ##      ## ##   ## #  # ##  ##     ##  ##    ## ##         ##  ##   ##     ##     ##   ##  ##        ##
  //  ##     ##   ##  ##  ##  ##  #####  #####    ##   ##        #####    #####   ###   ##   ##  ##        ##
  //  ##     #######  ##      ##  ##     ##  ##   #######        ##  ##   ##        ##  ##   ##  ##        ##
  //   ####  ##   ##  ##      ##  #####  ##   ##  ##   ##        ##   ##  #####  ####    #####   ######    ##
  //
  //===============================================================================================================

  Widget getCaptureResultBody() {
    print('***** getCaptureResultBody *****');
    switch (cameraMode) {
      case CameraMode.BARCODE:
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.file(
                file,
                fit: BoxFit.fitHeight,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  gradient:
                      bgGradient(Alignment.bottomCenter, Alignment.topCenter),
                ),
                padding: padding_x_s + padding_top_xl + padding_bottom_l,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            cameraStateController(CameraState.CAPTURING);
                            _initializeBarcodeCamera();
                          });
                        },
                        child: Container(
                          padding: padding_a_xs,
                          child: Icon(
                            DarwinFont.cancel,
                            color: DarwinWhite,
                            size: grid_spacer * 2.5,
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          width: grid_spacer * 14,
                          height: grid_spacer * 14,
                          alignment: Alignment.center,
                          child: Container(
                            width: grid_spacer * 10,
                            height: grid_spacer * 10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(grid_spacer * 12),
                              color: DarwinSuccess,
                            ),
                            child: Icon(
                              DarwinFont.check,
                              color: DarwinWhite,
                              size: grid_spacer * 4,
                            ),
                          ),
                        ),
                        onTap: () async {
                          DarwinCameraResult result = DarwinCameraResult(
                            file: file,
                            barcodeValue: rawBarcodeValue,
                          );
                          Navigator.pop(context, result);
                        },
                      ),
                      Opacity(
                        opacity: 0,
                        child: Container(
                          padding: padding_a_xs,
                          child: Icon(
                            DarwinFont.refresh,
                            color: DarwinWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                color: DarwinWhite.withOpacity(0.9),
                child: SafeArea(
                  child: Container(
                    padding: padding_x_xs + padding_top_s + padding_bottom_xs,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            style: secondaryLabelBold,
                            text: 'SCANNED RESULT\n',
                          ),
                          TextSpan(
                            style: secondaryH3Bold,
                            text: rawBarcodeValue.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
        break;
      case CameraMode.CAMERA:
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.file(
                file,
                fit: BoxFit.fitHeight,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  gradient:
                      bgGradient(Alignment.bottomCenter, Alignment.topCenter),
                ),
                padding: padding_x_s + padding_top_xl + padding_bottom_l,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          print('Cancel Tapped!');
                          setState(() {
                            cameraStateController(CameraState.CAPTURING);
                          });
                        },
                        child: Container(
                          padding: padding_a_s,
                          child: Icon(
                            DarwinFont.cancel,
                            color: DarwinWhite,
                            size: grid_spacer * 2.5,
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          width: grid_spacer * 14,
                          height: grid_spacer * 14,
                          alignment: Alignment.center,
                          child: Container(
                            width: grid_spacer * 10,
                            height: grid_spacer * 10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(grid_spacer * 12),
                              color: DarwinSuccess,
                            ),
                            child: Icon(
                              DarwinFont.check,
                              color: DarwinWhite,
                              size: grid_spacer * 4,
                            ),
                          ),
                        ),
                        onTap: () async {
                          DarwinCameraResult result = DarwinCameraResult(
                            file: file,
                          );
                          Navigator.pop(context, result);
                        },
                      ),
                      Opacity(
                        opacity: 0,
                        child: Container(
                          padding: padding_a_s,
                          child: Icon(
                            DarwinFont.refresh,
                            color: DarwinWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
        break;
      case CameraMode.VIDEO:
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: (isFileCompressionDone)
                  ? DarwinVideoPlayer(
                      videoFilePath: filePath,
                      fadeFromBottom: true,
                    )
                  : Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: DarwinBlack,
                    ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: padding_x_s + padding_top_xl + padding_bottom_l,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            cameraStateController(CameraState.CAPTURING);
                          });
                        },
                        child: Visibility(
                          visible: isFileCompressionDone,
                          child: Container(
                            padding: padding_a_s,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(grid_spacer * 6),
                              color: DarwinWhite,
                            ),
                            child: Icon(
                              DarwinFont.cancel,
                              color: DarwinDanger,
                              size: grid_spacer * 2.5,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: grid_spacer * 14,
                        height: grid_spacer * 14,
                      ),
                      GestureDetector(
                        onTap: () {
                          DarwinCameraResult result = DarwinCameraResult(
                            file: file,
                          );
                          Navigator.pop(context, result);
                        },
                        child: Visibility(
                          visible: isFileCompressionDone,
                          child: Container(
                            padding: padding_a_s,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(grid_spacer * 6),
                              color: DarwinWhite,
                            ),
                            child: Icon(
                              DarwinFont.check,
                              color: DarwinSuccess,
                              size: grid_spacer * 3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
        break;
    }
  }

  //==============================================================================================================================================
  //
  //   ####  ######    ###    ######  ##   ##   ####        #####     ###    #####           ####  ##   ##    ###    ##     ##   ####    #####
  //  ##       ##     ## ##     ##    ##   ##  ##           ##  ##   ## ##   ##  ##         ##     ##   ##   ## ##   ####   ##  ##       ##
  //   ###     ##    ##   ##    ##    ##   ##   ###         #####   ##   ##  #####          ##     #######  ##   ##  ##  ## ##  ##  ###  #####
  //     ##    ##    #######    ##    ##   ##     ##        ##  ##  #######  ##  ##         ##     ##   ##  #######  ##    ###  ##   ##  ##
  //  ####     ##    ##   ##    ##     #####   ####         #####   ##   ##  ##   ##         ####  ##   ##  ##   ##  ##     ##   ####    #####
  //
  //==============================================================================================================================================
  void changeStatusBarColor(theme) {
    if (theme == 'dark') {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    }
  }

  //========================================================================================================================
  //
  //   ####  ##   ##  ##   ##  ######  ######  #####  #####          #####   ##   ##  ######  ######   #####   ##     ##
  //  ##     ##   ##  ##   ##    ##      ##    ##     ##  ##         ##  ##  ##   ##    ##      ##    ##   ##  ####   ##
  //   ###   #######  ##   ##    ##      ##    #####  #####          #####   ##   ##    ##      ##    ##   ##  ##  ## ##
  //     ##  ##   ##  ##   ##    ##      ##    ##     ##  ##         ##  ##  ##   ##    ##      ##    ##   ##  ##    ###
  //  ####   ##   ##   #####     ##      ##    #####  ##   ##        #####    #####     ##      ##     #####   ##     ##
  //
  //========================================================================================================================
  Widget shutterButton() {
    return Container(
      height: grid_spacer * 14,
      width: grid_spacer * 14,
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            alignment: Alignment.center,
            duration: Duration(milliseconds: 100),
            width: cameraShutterSize,
            height: cameraShutterSize,
            decoration: BoxDecoration(
              color: DarwinWhite.withOpacity(0.25),
              borderRadius: BorderRadius.circular(grid_spacer * 12),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 100),
            top: cameraShutterPosition,
            left: cameraShutterPosition,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: grid_spacer * 8,
              height: grid_spacer * 8,
              decoration: BoxDecoration(
                color: DarwinWhite,
                borderRadius: BorderRadius.circular(grid_spacer * 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //================================================================================================================
  //
  //  #####    #####   ####   #####   #####    ####          #####   ##   ##  ######  ######   #####   ##     ##
  //  ##  ##   ##     ##     ##   ##  ##  ##   ##  ##        ##  ##  ##   ##    ##      ##    ##   ##  ####   ##
  //  #####    #####  ##     ##   ##  #####    ##  ##        #####   ##   ##    ##      ##    ##   ##  ##  ## ##
  //  ##  ##   ##     ##     ##   ##  ##  ##   ##  ##        ##  ##  ##   ##    ##      ##    ##   ##  ##    ###
  //  ##   ##  #####   ####   #####   ##   ##  ####          #####    #####     ##      ##     #####   ##     ##
  //
  //================================================================================================================
  Widget videoRecordingButton() {
    return Container(
      height: grid_spacer * 14,
      width: grid_spacer * 14,
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            alignment: Alignment.center,
            duration: Duration(milliseconds: 100),
            width: cameraShutterSize,
            height: cameraShutterSize,
            decoration: BoxDecoration(
              color: DarwinDanger.withOpacity(0.25),
              borderRadius: BorderRadius.circular(grid_spacer * 12),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 100),
            top: cameraShutterPosition,
            left: cameraShutterPosition,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: cameraInnerShutterSize,
              height: cameraInnerShutterSize,
              decoration: BoxDecoration(
                color: DarwinDanger,
                borderRadius: BorderRadius.circular(cameraInnerBorderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================================================================================================
  //
  //   ####    ###    ###    ###  #####  #####      ###          ####    ##  #####    #####   ####  ######  ##   #####   ##     ##
  //  ##      ## ##   ## #  # ##  ##     ##  ##    ## ##         ##  ##  ##  ##  ##   ##     ##       ##    ##  ##   ##  ####   ##
  //  ##     ##   ##  ##  ##  ##  #####  #####    ##   ##        ##  ##  ##  #####    #####  ##       ##    ##  ##   ##  ##  ## ##
  //  ##     #######  ##      ##  ##     ##  ##   #######        ##  ##  ##  ##  ##   ##     ##       ##    ##  ##   ##  ##    ###
  //   ####  ##   ##  ##      ##  #####  ##   ##  ##   ##        ####    ##  ##   ##  #####   ####    ##    ##   #####   ##     ##
  //
  //==================================================================================================================================
  Future<CameraController> changeController() async {
    cameraDescription =
        widget.cameras[(cameraDescription == widget.cameras[0]) ? 1 : 0];
    CameraController newController =
        CameraController(cameraDescription, resolutionPreset);
    await newController.initialize();
    return newController;
  }

  //=======================================================================================================================================
  //
  //   ####  ######    ###    #####    ######         ####   #####   ##   ##  ##     ##  ######  ####     #####   ##      ##  ##     ##
  //  ##       ##     ## ##   ##  ##     ##          ##     ##   ##  ##   ##  ####   ##    ##    ##  ##  ##   ##  ##      ##  ####   ##
  //   ###     ##    ##   ##  #####      ##          ##     ##   ##  ##   ##  ##  ## ##    ##    ##  ##  ##   ##  ##  ##  ##  ##  ## ##
  //     ##    ##    #######  ##  ##     ##          ##     ##   ##  ##   ##  ##    ###    ##    ##  ##  ##   ##  ##  ##  ##  ##    ###
  //  ####     ##    ##   ##  ##   ##    ##           ####   #####    #####   ##     ##    ##    ####     #####    ###  ###   ##     ##
  //
  //=======================================================================================================================================
  void startCountdownTimer() {
    setState(() {
      resetTimer = false;
    });
    const oneSec = const Duration(seconds: 1);
    countdownTimer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (resetTimer) {
            timer.cancel();
          } else {
            if (videoTimeInterval < 1) {
              timer.cancel();
              autoStopVideoRecording();
            } else {
              videoTimeInterval = videoTimeInterval - 1;
            }
          }
        },
      ),
    );
  }

  //====================================================================================================================================
  //
  //  #####    #####   ####  #####  ######         ####   #####   ##   ##  ##     ##  ######  ####     #####   ##      ##  ##     ##
  //  ##  ##   ##     ##     ##       ##          ##     ##   ##  ##   ##  ####   ##    ##    ##  ##  ##   ##  ##      ##  ####   ##
  //  #####    #####   ###   #####    ##          ##     ##   ##  ##   ##  ##  ## ##    ##    ##  ##  ##   ##  ##  ##  ##  ##  ## ##
  //  ##  ##   ##        ##  ##       ##          ##     ##   ##  ##   ##  ##    ###    ##    ##  ##  ##   ##  ##  ##  ##  ##    ###
  //  ##   ##  #####  ####   #####    ##           ####   #####    #####   ##     ##    ##    ####     #####    ###  ###   ##     ##
  //
  //====================================================================================================================================
  void resetCountdownTimer() {
    setState(() {
      resetTimer = true;
      videoTimeInterval = videoMaxTimeLimit;
    });
  }

  //======================================================================================================================================
  //
  //   ####  ######    ###    ######  #####         ####   #####   ##     ##  ######  #####     #####   ##      ##      #####  #####
  //  ##       ##     ## ##     ##    ##           ##     ##   ##  ####   ##    ##    ##  ##   ##   ##  ##      ##      ##     ##  ##
  //   ###     ##    ##   ##    ##    #####        ##     ##   ##  ##  ## ##    ##    #####    ##   ##  ##      ##      #####  #####
  //     ##    ##    #######    ##    ##           ##     ##   ##  ##    ###    ##    ##  ##   ##   ##  ##      ##      ##     ##  ##
  //  ####     ##    ##   ##    ##    #####         ####   #####   ##     ##    ##    ##   ##   #####   ######  ######  #####  ##   ##
  //
  //======================================================================================================================================
  void cameraStateController(cameraState) {
    if (cameraState == CameraState.CAPTURING) {
      setState(() {
        isImageCaptured = false;
      });
    } else if (cameraState == CameraState.CAPTURED) {
      setState(() {
        isImageCaptured = true;
      });
    }
  }

  //=======================================================================================================================
  //
  //   ####    ###    ###    ###  #####  #####      ###          #####   #####    #####  ##   ##  ##  #####  ##      ##
  //  ##      ## ##   ## #  # ##  ##     ##  ##    ## ##         ##  ##  ##  ##   ##     ##   ##  ##  ##     ##      ##
  //  ##     ##   ##  ##  ##  ##  #####  #####    ##   ##        #####   #####    #####  ##   ##  ##  #####  ##  ##  ##
  //  ##     #######  ##      ##  ##     ##  ##   #######        ##      ##  ##   ##      ## ##   ##  ##     ##  ##  ##
  //   ####  ##   ##  ##      ##  #####  ##   ##  ##   ##        ##      ##   ##  #####    ###    ##  #####   ###  ###
  //
  //=======================================================================================================================
  Widget previewCamera(cameraState) {
    print('INSIDE cameraState');
    if (cameraState == CameraState.CAPTURING) {
      return CameraPreview(cameraController);
    }
    if (cameraDescription == widget.cameras[1]) {
      return Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(0)
          ..rotateY(3),
        alignment: FractionalOffset.center,
        child: Image.file(
          file,
        ),
      );
    }
  }

  //=======================================================================================================================
  //
  //  ##   ##    ###    ##     ##  ####    ##      #####        #####     ###    #####     ####   #####   ####    #####
  //  ##   ##   ## ##   ####   ##  ##  ##  ##      ##           ##  ##   ## ##   ##  ##   ##     ##   ##  ##  ##  ##
  //  #######  ##   ##  ##  ## ##  ##  ##  ##      #####        #####   ##   ##  #####    ##     ##   ##  ##  ##  #####
  //  ##   ##  #######  ##    ###  ##  ##  ##      ##           ##  ##  #######  ##  ##   ##     ##   ##  ##  ##  ##
  //  ##   ##  ##   ##  ##     ##  ####    ######  #####        #####   ##   ##  ##   ##   ####   #####   ####    #####
  //
  //=======================================================================================================================
  void _handleResult({
    @required List<Barcode> barcodes,
    @required MediaQueryData data,
    @required Size imageSize,
  }) {
    // for (Barcode barcode in barcodes) {
    //   rawBarcodeValue = barcode.rawValue;
    // }

    // if (!cameraController.value.isStreamingImages) {
    //   return;
    // }
    // final EdgeInsets padding = data.padding;
    // final double maxLogicalHeight = data.size.height - padding.top - padding.bottom;

    // final double imageHeight = defaultTargetPlatform == TargetPlatform.iOS
    //     ? imageSize.height
    //     : imageSize.width;

    // final double imageScale = imageHeight / maxLogicalHeight;
    // final double halfWidth = imageScale * barcodePainterRectangleSize.width / 2;
    // final double halfHeight = imageScale * barcodePainterRectangleSize.height / 2;

    // final Offset center = imageSize.center(Offset.zero);
    // final Rect validRect = Rect.fromLTRB(
    //   center.dx - halfWidth,
    //   center.dy - halfHeight,
    //   center.dx + halfWidth,
    //   center.dy + halfHeight,
    // );

    // for (Barcode barcode in barcodes) {
    //   final Rect intersection = validRect.intersect(barcode.boundingBox);

    //   final bool doesContain = intersection == barcode.boundingBox;

    //   if (doesContain) {
    //     cameraController.stopImageStream().then((_) => takePicture());

    //     if (barcode.boundingBox.overlaps(validRect)) {
    //       print('🎯 Move closer to the barcode');
    //     } else {
    //       cameraStateController(CameraState.CAPTURED);
    //     }
    //     return;
    //   }
    // }
  }

  //=================================================================================================================
  //
  //  #####   ##   ##  ##  ##      ####          #####     ###    #####     #####    ####   #####   ####    #####
  //  ##  ##  ##   ##  ##  ##      ##  ##        ##  ##   ## ##   ##  ##   ##   ##  ##     ##   ##  ##  ##  ##
  //  #####   ##   ##  ##  ##      ##  ##        #####   ##   ##  #####    ##   ##  ##     ##   ##  ##  ##  #####
  //  ##  ##  ##   ##  ##  ##      ##  ##        ##  ##  #######  ##  ##   ##   ##  ##     ##   ##  ##  ##  ##
  //  #####    #####   ##  ######  ####          #####   ##   ##  ##   ##   #####    ####   #####   ####    #####
  //
  //=================================================================================================================
  Widget _buildResults() {
    bool barcodeFound = false;

    Widget noResultsWidget = Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          margin: margin_bottom_s,
          padding: padding_x_xs + padding_y_xxs,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(grid_spacer),
            color: DarwinWhite,
          ),
          child: Text(
            'No results!',
            style: Theme.of(context).textTheme.display1,
          ),
        ),
      ),
    );

    if (cameraScanResults == null ||
        cameraController == null ||
        !cameraController.value.isInitialized) {
      print('💎_scanResults == NULL');
      return noResultsWidget;
    }

    CustomPainter painter;

    final Size imageSize = Size(
      cameraController.value.previewSize.height,
      cameraController.value.previewSize.width,
    );

    print('🎊_scanResults: $cameraScanResults');

    // if (cameraScanResults is! List<Barcode>) {
    //   print('💎_scanResults is! List<Barcode>');
    //   return noResultsWidget;
    // }

    // if(cameraScanResults.length != 0) {
    //   barcodeFound = true;
    // }

    // if(barcodeFound) {
    //   cameraController.stopImageStream().then((_) {
    //     takePicture().then((_) {
    //       print('🎮');
    //       cameraStateController(CameraState.CAPTURED);
    //     });
    //   });
    //   _handleResult(
    //     barcodes: cameraScanResults,
    //     data: MediaQuery.of(context),
    //     imageSize: imageSize
    //   );
    // }

    painter = BarcodeDetectorPainter(imageSize, cameraScanResults);

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: painter,
        ),
      ),
    );
  }

  //==============================================================================================
  //
  //  ######    ###    ##  ##  #####        #####   ##   ####  ######  ##   ##  #####    #####
  //    ##     ## ##   ## ##   ##           ##  ##  ##  ##       ##    ##   ##  ##  ##   ##
  //    ##    ##   ##  ####    #####        #####   ##  ##       ##    ##   ##  #####    #####
  //    ##    #######  ## ##   ##           ##      ##  ##       ##    ##   ##  ##  ##   ##
  //    ##    ##   ##  ##  ##  #####        ##      ##   ####    ##     #####   ##   ##  #####
  //
  //==============================================================================================
  Future<String> takePicture() async {
    imageCache.clear();
    if (!cameraController.value.isInitialized) {
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      if (file.existsSync()) {
        await file.delete();
      }

      showLoader = true;
      await cameraController.takePicture(filePath);

      File _file = File(filePath);
      await compressFile(_file);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    showLoader = false;
    return filePath;
  }

  //========================================================================================
  //
  //   ####  ######    ###    #####    ######        ##   ##  ##  ####    #####   #####
  //  ##       ##     ## ##   ##  ##     ##          ##   ##  ##  ##  ##  ##     ##   ##
  //   ###     ##    ##   ##  #####      ##          ##   ##  ##  ##  ##  #####  ##   ##
  //     ##    ##    #######  ##  ##     ##           ## ##   ##  ##  ##  ##     ##   ##
  //  ####     ##    ##   ##  ##   ##    ##            ###    ##  ####    #####   #####
  //
  //========================================================================================
  Future<String> startVideoRecording() async {
    if (!cameraController.value.isInitialized) {
      return null;
    }

    // Do nothing if a recording is on progress
    if (cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      if (file.existsSync()) {
        await file.delete();
      }

      await cameraController.startVideoRecording(filePath);
      file = File(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }

    return filePath;
  }

  //===============================================================================
  //
  //   ####  ######   #####   #####         ##   ##  ##  ####    #####   #####
  //  ##       ##    ##   ##  ##  ##        ##   ##  ##  ##  ##  ##     ##   ##
  //   ###     ##    ##   ##  #####         ##   ##  ##  ##  ##  #####  ##   ##
  //     ##    ##    ##   ##  ##             ## ##   ##  ##  ##  ##     ##   ##
  //  ####     ##     #####   ##              ###    ##  ####    #####   #####
  //
  //===============================================================================
  Future<void> stopVideoRecording() async {
    if (!cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.stopVideoRecording();
      print('@@@@@@@@@ file @@@@@@@@ $file');
    } on CameraException catch (e) {
      print(e);
      return null;
    }

    videoThumbnail = await _flutterVideoCompress.getThumbnailWithFile(
      file.absolute.path,
      quality: 50,
    );
    print('@@@@@@@@@@--------- videoThumbnail: $videoThumbnail');
  }

  //========================================================================================================================
  //
  //    ###    ##   ##  ######   #####          ####  ######   #####   #####         ##   ##  ##  ####    #####   #####
  //   ## ##   ##   ##    ##    ##   ##        ##       ##    ##   ##  ##  ##        ##   ##  ##  ##  ##  ##     ##   ##
  //  ##   ##  ##   ##    ##    ##   ##         ###     ##    ##   ##  #####         ##   ##  ##  ##  ##  #####  ##   ##
  //  #######  ##   ##    ##    ##   ##           ##    ##    ##   ##  ##             ## ##   ##  ##  ##  ##     ##   ##
  //  ##   ##   #####     ##     #####         ####     ##     #####   ##              ###    ##  ####    #####   #####
  //
  //========================================================================================================================
  void autoStopVideoRecording() {
    resetCountdownTimer();
    setState(() {
      showLoader = true;
    });
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      cameraShutterSize = grid_spacer * 10;
      cameraShutterPosition = grid_spacer;
      cameraInnerShutterSize = grid_spacer * 8;
      cameraInnerBorderRadius = grid_spacer * 10;
      showHeader = true;
      showReverseCamera = true;
      cameraStateController(CameraState.CAPTURED);
      Timer(Duration(milliseconds: 200), () {
        _videoRecordingState = VideoRecordingState.START;
      });
      compressFile(file).then((_) {
        showLoader = false;
      });
    });
  }

  //======================================================================================================
  //
  //   ####   #####   ###    ###  #####   #####    #####   ####   ####        #####  ##  ##      #####
  //  ##     ##   ##  ## #  # ##  ##  ##  ##  ##   ##     ##     ##           ##     ##  ##      ##
  //  ##     ##   ##  ##  ##  ##  #####   #####    #####   ###    ###         #####  ##  ##      #####
  //  ##     ##   ##  ##      ##  ##      ##  ##   ##        ##     ##        ##     ##  ##      ##
  //   ####   #####   ##      ##  ##      ##   ##  #####  ####   ####         ##     ##  ######  #####
  //
  //======================================================================================================
  Future<void> compressFile(File file) async {
    // print('@@@@@@@@@@@@@@@@@ original file length: ${file.lengthSync()}');
    var result;
    if (cameraMode == CameraMode.VIDEO) {
      result = await _flutterVideoCompress.compressVideo(
        file.absolute.path,
        quality: VideoQuality.HighestQuality,
        deleteOrigin: false,
      );
      // print('@@@@@@@@@@@@@@@@@RESULT: $result');
      // debugPrint(result.toJson().toString());
      await result.file.copySync(filePath);
      await result.file.delete();
      // print('@@@@@@@@@@@@@@@@@ new file length: ${file.lengthSync()}');
    } else {
      result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 50,
        autoCorrectionAngle: true,
        keepExif: true,
      );
      await file.delete();
      await file.writeAsBytes(result);
      print('new file length: ${result.length}');
    }
    print('^^^^^^^^^^^^^^^^^^^isFileCompressionDone: $isFileCompressionDone');
    setState(() {
      isFileCompressionDone = true;
    });
    print('^^^^^^^^^^^^^^^^^^^isFileCompressionDone: $isFileCompressionDone');
    print(file.absolute.path);
  }
}

class BGPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.black.withOpacity(0.6), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ClipBarcode extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    print(size);
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(30, size.height / 2 - 120, size.width - 60, 240),
          Radius.circular(grid_spacer * 3)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    return true;
  }
}

//===========================================================================================================================
//
//  #####     ###    #####     ####   #####   ####    #####        #####     ###    ##  ##     ##  ######  #####  #####
//  ##  ##   ## ##   ##  ##   ##     ##   ##  ##  ##  ##           ##  ##   ## ##   ##  ####   ##    ##    ##     ##  ##
//  #####   ##   ##  #####    ##     ##   ##  ##  ##  #####        #####   ##   ##  ##  ##  ## ##    ##    #####  #####
//  ##  ##  #######  ##  ##   ##     ##   ##  ##  ##  ##           ##      #######  ##  ##    ###    ##    ##     ##  ##
//  #####   ##   ##  ##   ##   ####   #####   ####    #####        ##      ##   ##  ##  ##     ##    ##    #####  ##   ##
//
//===========================================================================================================================
// class BarcodeDetectorPainter extends CustomPainter {
//   BarcodeDetectorPainter(this.absoluteImageSize, this.barcodeLocations);

//   final Size absoluteImageSize;
//   final List<Barcode> barcodeLocations;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final double scaleX = size.width / absoluteImageSize.width;
//     final double scaleY = size.height / absoluteImageSize.height;

//     Rect scaleRect(Barcode barcode) {
//       return Rect.fromLTRB(
//         barcode.boundingBox.left * scaleX,
//         barcode.boundingBox.top * scaleY,
//         barcode.boundingBox.right * scaleX,
//         barcode.boundingBox.bottom * scaleY,
//       );
//     }

//     final Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     for (Barcode barcode in barcodeLocations) {
//       paint.color = DarwinDanger;
//       canvas.drawRect(scaleRect(barcode), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
//     print('🎨 Inside Painter');
//     return oldDelegate.absoluteImageSize != absoluteImageSize ||
//         oldDelegate.barcodeLocations != barcodeLocations;
//   }
// }

class Rectangle {
  const Rectangle({this.width, this.height, this.color});

  final double width;
  final double height;
  final Color color;

  static Rectangle lerp(Rectangle begin, Rectangle end, double t) {
    Color color;
    if (t > .5) {
      color = Color.lerp(begin.color, end.color, (t - .5) / .25);
    } else {
      color = begin.color;
    }

    return Rectangle(
      width: lerpDouble(begin.width, end.width, t),
      height: lerpDouble(begin.height, end.height, t),
      color: color,
    );
  }
}

class RectangleTween extends Tween<Rectangle> {
  RectangleTween(Rectangle begin, Rectangle end)
      : super(begin: begin, end: end);

  @override
  Rectangle lerp(double t) => Rectangle.lerp(begin, end, t);
}

class RectangleOutlinePainter extends CustomPainter {
  RectangleOutlinePainter({
    @required this.animation,
    this.strokeWidth = 3,
  }) : super(repaint: animation);

  final Animation<Rectangle> animation;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rectangle rectangle = animation.value;

    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = rectangle.color
      ..style = PaintingStyle.stroke;

    final Offset center = size.center(Offset.zero);
    final double halfWidth = rectangle.width / 2;
    final double halfHeight = rectangle.height / 2;

    final Rect rect = Rect.fromLTRB(
      center.dx - halfWidth,
      center.dy - halfHeight,
      center.dx + halfWidth,
      center.dy + halfHeight,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(RectangleOutlinePainter oldDelegate) => false;
}

class RectangleTracePainter extends CustomPainter {
  RectangleTracePainter({
    @required this.animation,
    @required this.rectangle,
    this.strokeWidth = 3,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Rectangle rectangle;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double value = animation.value;

    final Offset center = size.center(Offset.zero);
    final double halfWidth = rectangle.width / 2;
    final double halfHeight = rectangle.height / 2;

    final Rect rect = Rect.fromLTRB(
      center.dx - halfWidth,
      center.dy - halfHeight,
      center.dx + halfWidth,
      center.dy + halfHeight,
    );

    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = rectangle.color;

    final double halfStrokeWidth = strokeWidth / 2;

    final double heightProportion = (halfStrokeWidth + rect.height) * value;
    final double widthProportion = (halfStrokeWidth + rect.width) * value;

    canvas.drawLine(
      Offset(rect.right, rect.bottom + halfStrokeWidth),
      Offset(rect.right, rect.bottom - heightProportion),
      paint,
    );

    canvas.drawLine(
      Offset(rect.right + halfStrokeWidth, rect.bottom),
      Offset(rect.right - widthProportion, rect.bottom),
      paint,
    );

    canvas.drawLine(
      Offset(rect.left, rect.top - halfStrokeWidth),
      Offset(rect.left, rect.top + heightProportion),
      paint,
    );

    canvas.drawLine(
      Offset(rect.left - halfStrokeWidth, rect.top),
      Offset(rect.left + widthProportion, rect.top),
      paint,
    );
  }

  @override
  bool shouldRepaint(RectangleTracePainter oldDelegate) => false;
}

class DarwinCameraResult {
  final File file;
  final String barcodeValue;

  bool get isFileAvailable {
    if (file == null) {
      return false;
    } else {
      return true;
    }
  }

  DarwinCameraResult({
    this.file,
    this.barcodeValue,
  });
}
