import 'package:camera/camera.dart';
import 'package:darwin_design_system/darwin_design_system.dart';
import 'package:flutter/material.dart';

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
  final Function onBackPress;

  const RenderCameraStream({
    Key key,
    @required this.cameraController,
    @required this.showHeader,
    this.onBackPress,
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
}
