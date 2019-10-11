import 'dart:io';

import 'package:camera/camera.dart';
import 'package:darwin_design_system/darwin_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

double captureButtonInnerBorderRadius = grid_spacer * 10;
double captureButtonInnerShutterSize = grid_spacer * 8;
double captureButtonPosition = grid_spacer;
double captureButtonSize = grid_spacer * 10;

enum CameraState { NOT_CAPTURING, CAPTURING, CAPTURED }

class DarwinCameraHelper {
  ///
  static LinearGradient backgroundGradient(
    AlignmentGeometry begin,
    AlignmentGeometry end,
  ) {
    return LinearGradient(
      colors: [
        Colors.black,
        Colors.transparent,
      ],
      begin: begin,
      end: end,
    );
  }

  ///
  ///
  /// Captures image from the selected Camera.
  static Future<String> captureImage(
    CameraController cameraController,
    String filePath,
  ) async {
    imageCache.clear();
    if (!cameraController.value.isInitialized) {
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      return null;
    }
    File file = File(filePath);

    try {
      if (file.existsSync()) {
        await file.delete();
      }

      await cameraController.takePicture(filePath);

      file = File(filePath);
      await compressImage(file);
    } on CameraException catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      return null;
    }
    return filePath;
  }

  ///
  ///
  /// Compress Image saved in phone internal storage.
  static compressImage(File file) async {
    var result;
    result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 50,
      autoCorrectionAngle: true,
      keepExif: true,
    );
    await file.delete();
    await file.writeAsBytes(result);
    print('[+] COMPRESSED FILE SIZE: ${result.length}');
  }



  static returnResult(context, {File file}) {
    var result = DarwinCameraResult(file: file);
    Navigator.pop(context, result);
  }



}



class LoaderOverlay extends StatelessWidget {
  bool isVisible;

  LoaderOverlay({Key key, bool visible, String helperText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class RenderCameraStream extends StatelessWidget {
  final CameraController cameraController;
  final bool showHeader;
  final bool showFooter;
  final Widget leftFooterButton;
  final Widget centerFooterButton;
  final Widget rightFooterButton;
  final Function onBackPress;

  const RenderCameraStream({
    Key key,

    ///
    @required this.cameraController,
    @required this.showHeader,
    this.onBackPress,

    ///
    @required this.showFooter,
    this.leftFooterButton,
    this.centerFooterButton,
    this.rightFooterButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop: () async {
      //   return true;
      // },
      child: Stack(
        children: <Widget>[
          getCameraStream(context),
          getHeader(showHeader),
          getFooter(showFooter),
        ],
      ),
    );
  }

  ///
  /// This will render stream on camera on the screen.
  /// Scaling is important here as the default camera stream
  /// isn't perfect.
  Widget getCameraStream(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double cameraAspectRatio = cameraController.value.aspectRatio;

    ///
    return ClipRect(
      child: Container(
        child: Transform.scale(
          scale: cameraAspectRatio / size.aspectRatio,
          child: Center(
            child: AspectRatio(
              aspectRatio: cameraAspectRatio,
              child: CameraPreview(cameraController),
              // (cameraMode == CameraMode.BARCODE)
              //     ? Container()
              //     : previewCamera(cameraState),
            ),
          ),
        ),
      ),
    );
  }

  ///
  /// Header is aligned in the top center
  /// It will show back button onf this page
  Widget getHeader(bool showHeader) {
    return Visibility(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            gradient: DarwinCameraHelper.backgroundGradient(
              Alignment.topCenter,
              Alignment.bottomCenter,
            ),
          ),
          padding: padding_x_s + padding_top_s + padding_bottom_xl,
          child: SafeArea(
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (onBackPress != null) {
                      onBackPress();
                    }
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
      ),
    );
  }

  Widget getFooter(bool showFooter) {
    return Visibility(
      visible: showFooter,
      child: CameraFooter(
        leftButton: leftFooterButton,
        centerButton: centerFooterButton,
        rightButton: rightFooterButton,
      ),
    );
  }
}

class RenderCapturedImage extends StatelessWidget {
  final File file;

  ///
  final Widget leftFooterButton;
  final Widget centerFooterButton;
  final Widget rightFooterButton;

  ///
  const RenderCapturedImage({
    Key key,
    @required this.file,
    @required this.leftFooterButton,
    @required this.centerFooterButton,
    @required this.rightFooterButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        CameraFooter(
          leftButton: leftFooterButton,
          centerButton: centerFooterButton,
          rightButton: rightFooterButton,
        ),
      ],
    );
  }
}

class CameraFooter extends StatelessWidget {
  final Widget leftButton;
  final Widget centerButton;
  final Widget rightButton;

  CameraFooter({
    Key key,
    @required this.leftButton,
    @required this.centerButton,
    @required this.rightButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: DarwinCameraHelper.backgroundGradient(
            Alignment.bottomCenter,
            Alignment.topCenter,
          ),
        ),
        padding: padding_x_s + padding_top_xl + padding_bottom_l,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[leftButton, centerButton, rightButton],
          ),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  ///
  final Function onTap;
  final double opacity;

  ///
  CancelButton({
    Key key,
    @required this.onTap,
    @required this.opacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        padding: padding_a_s,
        child: Opacity(
          opacity: opacity,
          child: Icon(
            DarwinFont.cancel,
            color: DarwinDanger,
          ),
        ),
      ),
    );
  }
}

class CaptureButton extends StatelessWidget {
  final double buttonSize;
  final double buttonPosition;
  final Function onTap;

  CaptureButton({
    Key key,
    @required this.buttonSize,
    @required this.buttonPosition,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: getButtonBody(),
      onTap: onTap,
    );
  }

  Widget getButtonBody() {
    return Container(
      height: grid_spacer * 14,
      width: grid_spacer * 14,
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            alignment: Alignment.center,
            duration: Duration(milliseconds: 100),
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: DarwinWhite.withOpacity(0.25),
              borderRadius: BorderRadius.circular(grid_spacer * 12),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 100),
            top: buttonPosition,
            left: buttonPosition,
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
}

class ConfirmButton extends StatelessWidget {
  final Function onTap;
  const ConfirmButton({
    Key key,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: grid_spacer * 14,
        height: grid_spacer * 14,
        alignment: Alignment.center,
        child: Container(
          width: grid_spacer * 10,
          height: grid_spacer * 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(grid_spacer * 12),
            color: DarwinSuccess,
          ),
          child: Icon(
            DarwinFont.check,
            color: DarwinWhite,
            size: grid_spacer * 4,
          ),
        ),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}

///
///
/// This widget will send event to toggle camera.
class ToggleCameraButton extends StatelessWidget {
  final Function onTap;
  const ToggleCameraButton({Key key, @required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: padding_a_s,
        child: Icon(
          DarwinFont.refresh,
          color: DarwinWhite,
        ),
      ),
      onTap: onTap,
    );
  }
}

class DarwinCameraResult {
  ///
  final File file;

  /// Scanned text in returned in case of Barcode Scanner.
  final String scannedText;

  bool get isFileAvailable {
    if (file == null) {
      return false;
    } else {
      return true;
    }
  }

  DarwinCameraResult({
    this.file,
    this.scannedText,
  });
}
