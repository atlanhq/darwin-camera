#import "DarwinCameraPlugin.h"
#import <darwin_camera/darwin_camera-Swift.h>

@implementation DarwinCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDarwinCameraPlugin registerWithRegistrar:registrar];
}
@end
