//
//  StreamHandler.m
//  Runner
//
//  Created by xt.sun on 2022/6/8.
//

#import "StreamHandler.h"
#import <Foundation/Foundation.h>
#import "Flutter/FlutterChannels.h"

typedef void (^StreamCallback) (FlutterEventSink* eventSink);

@implementation StreamHandler
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events{
    self.eventSink = events;
    return  nil;
}
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments{
    self.eventSink = nil;
    return  nil;
}
@end
