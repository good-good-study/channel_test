#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "RtmManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    FlutterViewController* controller=(FlutterViewController*) self.window.rootViewController;
    NSObject<FlutterBinaryMessenger>*  binaryMessenger=controller.binaryMessenger;
    
    // 初始化Rtm
    [[RtmManagerController alloc] registerWithMessager:binaryMessenger];
    
    // 获取手机电量🔋
    [self initBatteryChannel:binaryMessenger];
    
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


// 以下代码是通过MethodChannel 获取系统电量值，然后传递给Flutter.
// FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;
- (void) initBatteryChannel : (NSObject<FlutterBinaryMessenger>*) binaryMessenger {
    FlutterMethodChannel *methodChannel=[FlutterMethodChannel methodChannelWithName:@"samples.flutter.dev/battery" binaryMessenger:binaryMessenger];
    __weak typeof(self) weakSelf = self;
    [methodChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if([@"getBatteryLevel" isEqualToString: call.method]){
            int batteryLebel = [weakSelf getBatteryLevel];
            if(batteryLebel == -1){
                result([FlutterError
                        errorWithCode : @"UNAVAILABLE"
                        message: @"Battery info unavailable"
                        details: nil]);
            }else{
                result(@(batteryLebel));
            }
        }else{
            result(FlutterMethodNotImplemented);
        }
    }];
}

- (int) getBatteryLevel {
    UIDevice *device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled= YES;
    if(device.batteryState==UIDeviceBatteryStateUnknown){
        return -1;
    }
    return (int) (device.batteryLevel * 100);
}

@end
