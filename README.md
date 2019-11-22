<p align="center">
  <img width="50%" src="https://user-images.githubusercontent.com/9272830/69432210-3fb37080-0d5f-11ea-8c07-b54a09380955.png">
<p>

# Darwin Camera
<img src="https://user-images.githubusercontent.com/9272830/68128635-18c30500-ff3e-11e9-8a32-c32496d5856f.jpg" width="35%" align="right">
 </img> 

<img src="https://img.shields.io/badge/license-MIT-green"></img>


Darwin camera makes it super easy to add camera to your Flutter app. It uses the official camera plugin implementation underneath.

- Captures RAW image at maximum resolution supported by the device camera.
- Provides a toggle between front and back camera.
  - You can configure what it defaults to on opening.
- Provides configuration to compression quality of the captured image.
  - Uses the [flutter_image_compress](https://pub.dev/packages/flutter_image_compress) library.
- Provides a minimal UI for the reviewing the capture before saving image.
- Supports both Android and iOS.



| Camera Stream                  | Preview Captured Image         |
|     :---:       |     :---:       |
| <img src="https://user-images.githubusercontent.com/9272830/69421271-a11b1580-0d46-11ea-9dcf-b3d508a2f381.jpeg" width="50%" ></img> | <img src="https://user-images.githubusercontent.com/9272830/69421319-c3149800-0d46-11ea-9664-198faf125a60.jpeg" width="50%" ></img> |
| Press the `white circular button` to capture image. | Press the `green button` to save the image. |
| Press the button at the bottom right to `toggle camera`. | Press the close button to `discard` the `captured image`. |





## Getting Started

In your flutter project add `darwin_camera` as a dependency in `pubspec.yaml`:

```yml
dependencies:
  ...
  darwin_camera:
    git: https://github.com/atlanhq/darwin-camera
    
```
### iOS

Add two rows to the `ios/Runner/Info.plist`:

* one with the key `Privacy - Camera Usage Description` and a usage description.
* and one with the key `Privacy - Microphone Usage Description` and a usage description.

Or in text format add the key:

```xml
<key>NSCameraUsageDescription</key>
<string>Can I use the camera please?</string>
<key>NSMicrophoneUsageDescription</key>
<string>Can I use the mic please?</string>
```

### Android

Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```
minSdkVersion 21
```



## Usage example
```dart
import 'package:darwin_camera/darwin_camera.dart';

 DarwinCameraResult result = await Navigator.push(
   context,
   MaterialPageRoute(
     builder: (context) => DarwinCamera(
       cameraDescription: cameraDescription,
       filePath: filePath,
       resolution: ResolutionPreset.high,
       defaultToFrontFacing: false,
       quality: 90,
     ),
   ),
 );

if (result != null && result.isFileAvailable) {
   /// File object returned by Camera.
   print(result.file);
   /// Path where the file is faced. 
   print(result.file.path);
 }

```

### `DarwinCamera` configuration 
This widget captures an image and save it at the path provided by you.

```dart
DarwinCamera({
  
  ///
  /// Flag to enable/disable image compression.
  bool enableCompression = false, 
  
  ///
  /// Disables swipe based native back functionality provided by iOS.
  bool disableNativeBackFunctionality = false,
  
  /// @Required
  /// List of cameras availale in the device.
  /// 
  /// How to get the list available cameras?
  /// `List<CameraDescription> cameraDescription = await availableCameras();`
  List<CameraDescription> cameraDescription, 
  
  /// @Required
  
  /// Path where the image file will be saved.
  String filePath, 
  
  /// 
  /// Resolution of the image captured
  /// Possible values:
  /// 1. ResolutionPreset.high
  /// 2. ResolutionPreset.medium
  /// 3. ResolutionPreset.low
  ResolutionPreset resolution = ResolutionPreset.high, 

  ///
  /// Open front camera instead of back camera on launch.
  bool defaultToFrontFacing = false;

  ///
  /// Decides the quality of final image captured.
  /// Possible values `0 - 100`
  int quality = 90;

})

```

## Complete example with permission handling.
See the [example](https://github.com/atlanhq/darwin-camera/tree/master/example) directory in the github repository


## Tests

```bash
cd example
flutter drive --target=test_driver/app.dart
```

## How to contribute?
See [CONTRIBUTING.md](https://github.com/atlanhq/darwin-camera/blob/master/CONTRIBUTING.md)


<img src="https://user-images.githubusercontent.com/408863/66741678-a78ab780-ee93-11e9-8d90-b274af222339.png" align="centre" />

