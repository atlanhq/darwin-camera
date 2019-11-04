// import 'dart:async';
// import 'dart:io';

// // import 'package:collect/app/configuration/print.dart';
// import 'package:darwin_design_system/darwin_design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class LoaderOverlay extends StatelessWidget {
//   bool isVisible;
  
//   LoaderOverlay({Key key, bool visible, String helperText}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

// class DarwinVideoPlayer extends StatefulWidget {
//   final String videoFilePath;
//   final bool fadeFromBottom;

//   DarwinVideoPlayer({
//     @required this.videoFilePath,
//     this.fadeFromBottom,
//   });

//   @override
//   _DarwinVideoPlayerState createState() => _DarwinVideoPlayerState();
// }

// class _DarwinVideoPlayerState extends State<DarwinVideoPlayer> {
//   VideoPlayerController _controller;
//   bool _isPlaying = false;
//   Duration _duration;
//   Duration _position;
//   bool _isEnd = false;

//   @override
//   void initState() {
//     _controller = VideoPlayerController.file(File(widget.videoFilePath))
//       ..addListener(() {
//         final bool isPlaying = _controller.value.isPlaying;
//         if (isPlaying != _isPlaying) {
//           setState(() {
//             _isPlaying = isPlaying;
//           });
//         }
//         Timer.run(() {
//           this.setState(() {
//             _position = _controller.value.position;
//           });
//         });
//         setState(() {
//           _duration = _controller.value.duration;
//         });
//         _duration?.compareTo(_position) == 0 ||
//                 _duration?.compareTo(_position) == -1
//             ? this.setState(() {
//                 _isEnd = true;
//               })
//             : this.setState(() {
//                 _isEnd = false;
//               });
//       })
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//       });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     bool _fadeFromBottom = widget.fadeFromBottom ?? false;
//     String currentDuration =
//         '${_position?.inMinutes.toString().padLeft(2, '0')}:${_position?.inSeconds.toString().padLeft(2, '0')}';
//     String totalDuration =
//         '${_duration?.inMinutes.toString().padLeft(2, '0')}:${_duration?.inSeconds.toString().padLeft(2, '0')}';
//     print('_controller.value =======>>>>> ${_controller.value}');
//     if (_isEnd == true) {
//       _controller.seekTo(Duration.zero);
//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         backgroundColor: DarwinBlack,
//         body: Stack(
//           children: <Widget>[
//             Center(
//               child: _controller.value.initialized
//                   ? Transform.scale(
//                       scale: _controller.value.aspectRatio / size.aspectRatio,
//                       child: AspectRatio(
//                         aspectRatio: _controller.value.aspectRatio,
//                         child: VideoPlayer(_controller),
//                       ))
//                   : Container(),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       (_fadeFromBottom) ? Colors.black : Colors.transparent,
//                       Colors.transparent,
//                     ],
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                   ),
//                 ),
//                 padding: padding_x_s + padding_top_xl + padding_bottom_l,
//                 child: SafeArea(
//                   child: GestureDetector(
//                     child: Container(
//                       width: grid_spacer * 14,
//                       height: grid_spacer * 14,
//                       alignment: Alignment.center,
//                       child: Container(
//                         width: grid_spacer * 10,
//                         height: grid_spacer * 10,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(grid_spacer * 12),
//                         ),
//                         child: Icon(
//                           // _controller.value.isPlaying ? DarwinFont.stop : DarwinFont.play,
//                           _controller.value.isPlaying
//                               ? Icons.pause
//                               : Icons.play_arrow,
//                           color: DarwinWhite,
//                           size: grid_spacer * 8,
//                         ),
//                       ),
//                     ),
//                     onTap: () {
//                       setState(() {
//                         _controller.value.isPlaying
//                             ? _controller.pause()
//                             : _controller.play();
//                       });
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.topCenter,
//               child: Container(
//                 width: double.infinity,
//                 height: MediaQuery.of(context).size.height * 0.5,
//                 padding: padding_x_xs + padding_top_xs,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       (_fadeFromBottom) ? Colors.black : Colors.transparent,
//                       Colors.transparent,
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Column(
//                     children: <Widget>[
//                       VideoProgressIndicator(
//                         _controller,
//                         allowScrubbing: true,
//                         colors: VideoProgressColors(
//                           backgroundColor: DarwinGrayDark.withOpacity(0.5),
//                           bufferedColor: DarwinGrayDark.withOpacity(0.5),
//                           playedColor: DarwinWhite,
//                         ),
//                       ),
//                       Container(
//                         margin: margin_top_xxs,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             Text(
//                               currentDuration,
//                               style:
//                                   secondaryPBold.copyWith(color: DarwinWhite),
//                             ),
//                             Text(
//                               totalDuration,
//                               style:
//                                   secondaryPBold.copyWith(color: DarwinWhite),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
