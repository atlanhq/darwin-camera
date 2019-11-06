import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:darwin_camera/darwin_camera.dart';

void main() {
  // const MethodChannel channel = MethodChannel('darwin_camera');

  group("Test UI Library", () {
    test("test: function: backgroundGradient : PASS", () {
      Alignment begin = Alignment.topCenter;
      Alignment end = Alignment.bottomCenter;

      LinearGradient correctResult = LinearGradient(
        colors: [
          Colors.black,
          Colors.transparent,
        ],
        begin: begin,
        end: end,
      );

      ///
      ///
      LinearGradient data = DarwinCameraHelper.backgroundGradient(
        Alignment.topCenter,
        Alignment.bottomCenter,
      );

      expect(data, correctResult);

      ///
    });
  });

  ///
  ///
  ///
  
  
}
