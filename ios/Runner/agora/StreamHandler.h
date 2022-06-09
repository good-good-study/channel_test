//
//  StreamHandler.h
//  Runner
//
//  Created by xt.sun on 2022/6/8.
//

#import <Foundation/Foundation.h>
#import "Flutter/FlutterChannels.h"

@interface StreamHandler : NSObject <FlutterStreamHandler>
@property  FlutterEventSink _Nullable  eventSink;
- (FlutterError* _Nullable) onListenWithArguments:(id _Nullable) arguments eventSink:(FlutterEventSink _Nullable ) events;
- (FlutterError* _Nullable) onCancelWithArguments:(id _Nullable) arguments;
@end
