# Darwin Camera Example
Demonstrates how to use the darwin_camera plugin.

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