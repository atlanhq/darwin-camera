# Darwin Camera

Darwin Camera plugin for [Flutter](https://flutter.io).
Supports both iOS and Android.

* Capture image, video and barcode (with scanned barcode text)
* Video player for previewing captured video using [video_player](https://pub.dev/packages/video_player).
* Image compression using [flutter_image_compress](https://pub.dev/packages/flutter_image_compress)
* Video compression using [flutter_video_compress](https://pub.dev/packages/flutter_video_compress)

## Getting Started

In your flutter project add the dependency:

```yml
dependencies:
  ...
  darwin_camera: ^0.0.1
```

For help getting started with Flutter, view the online
[documentation](https://flutter.io/).

## Usage example



Import `darwin_camera.dart`

```dart
import 'package:darwin_camera/core.dart';
```

### Creating a Image capture Widget

This widget captures an image at a provided file path.

```dart
DarwinCamera({
  filePath: 'path-to-file',
  resolution: ResolutionPresets.high,
  shouldCompress: true
})
```
