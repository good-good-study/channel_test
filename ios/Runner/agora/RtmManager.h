//
//  RtmManager.h
//  Runner
//
//  Created by xt.sun on 2022/6/8.
//

#import <AgoraRtmkit/AgoraRtmKit.h>

@interface RtmManagerController : NSObject
- (RtmManagerController*) registerWithMessager : (NSObject<FlutterBinaryMessenger>*) binaryMessager;
@end
