import 'package:camera/new/camera.dart';
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

// class CameraScaffold extends StatelessWidget {
//   final CameraController cameraController;
//   const CameraScaffold({
//     Key key,
//     @required this.cameraController,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Stack(
//         children: <Widget>[
//           ClipRect(
//             child: Container(
//               child: Transform.scale(
//                 scale: cameraController.value.aspectRatio / size.aspectRatio,
//                 child: Center(
//                   child: AspectRatio(
//                     aspectRatio: cameraController.value.aspectRatio,
//                     child: (cameraMode == CameraMode.BARCODE)
//                         ? Container()
//                         : previewCamera(cameraState),
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
