import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
    String filePath, {
    bool enableCompression = true,
    int quality,
  }) async {
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
      if (enableCompression == true) {
        await compressImage(file, quality);
      }
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
  static compressImage(File file, int quality) async {
    var result;
    result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
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
