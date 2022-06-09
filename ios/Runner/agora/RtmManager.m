//
//  Agora Rtm 云信令（实时消息），用于音视频会议邀请。
//
//  Created by xt.sun on 2022/6/8.
//

#import <Flutter/Flutter.h>
#import "RtmManager.h"
#import "StreamHandler.h"
#import "Flutter/FlutterChannels.h"
#import <AgoraRtmKit/AgoraRtmKit.h>

static NSString* RTM_CHANNEL=@"io.agora.rtm.channel";
static NSString* RTM_EVENT_CHANNEL=@"io.agora.rtm.event.channel";
static NSString* RTM_MSG_EVENT_CHANNEL=@"io.agora.rtm.message.channel";

@interface RtmManagerController() <AgoraRtmCallDelegate,AgoraRtmDelegate>
@property(strong,nonatomic) AgoraRtmKit *singleEngine;
@property(strong,nonatomic) RtmManagerController* instance;
@property StreamHandler* rtmEventStreamHandler;
@property StreamHandler* rtmEventMsgStreamHandler;
@property NSString* appId;
@property AgoraRtmRemoteInvitation* invitation;
@end

@implementation RtmManagerController

// 注册Rtm消息通道。
- (RtmManagerController *)registerWithMessager:(NSObject<FlutterBinaryMessenger> *)binaryMessager{
    if(!_instance){
        _instance=[[RtmManagerController alloc] init];
        [self registerChannels : binaryMessager];
    }
    return _instance;
}

/**
 * 初始化Rtm引擎
 */
- (AgoraRtmKit *) getRtmEngine{
    if(!self.singleEngine){
        self.singleEngine=[[AgoraRtmKit alloc] initWithAppId:self.appId delegate:self];
        // 设置会议邀请回调
        self.singleEngine.rtmCallKit.callDelegate = self;
    }
    return self.singleEngine;
}

/**
 * 获取 RtmCallKit
 */
- (AgoraRtmCallKit *) rtmCallKit{
    return [self getRtmEngine].rtmCallKit;
}

/**
 * 注册RTM消息通道。
 */
- (void) registerChannels : (NSObject<FlutterBinaryMessenger>*) binaryMessager{
    // 处理RTM基本事件动作：RTM 登录、登出。
    FlutterMethodChannel* rtmMethodChannel=[FlutterMethodChannel methodChannelWithName:RTM_CHANNEL binaryMessenger:binaryMessager];
    // 处理RTM接收到音视频邀请事件。
    FlutterEventChannel* rtmEventChannel = [FlutterEventChannel eventChannelWithName:RTM_EVENT_CHANNEL binaryMessenger:binaryMessager];
    // 处理接收到的RTM云信令（实时消息）。
    FlutterEventChannel* rtmMsgEventChannel = [FlutterEventChannel eventChannelWithName:RTM_MSG_EVENT_CHANNEL binaryMessenger:binaryMessager];
    // 设置事件回调。
    [rtmMethodChannel setMethodCallHandler:[self methodCallHandler]];
    // 设置单向数据流
    self.rtmEventStreamHandler =[[StreamHandler alloc]init];
    self.rtmEventMsgStreamHandler = [[StreamHandler alloc]init];
    [rtmEventChannel setStreamHandler: self.rtmEventStreamHandler];
    [rtmMsgEventChannel setStreamHandler:self.rtmEventMsgStreamHandler];
}

/**
 * MethodChannel 回调，用于处理 Rtm 的登录、退登、音视频会议的接受、拒绝。
 */
- (FlutterMethodCallHandler) methodCallHandler{
    return  ^(FlutterMethodCall * _Nonnull call, FlutterResult _Nonnull result) {
        NSString* method = call.method;
        NSDictionary* arguments = call.arguments;
        NSLog(@"收到来自flutter的参数：%@",arguments);
        
        if([@"login" isEqualToString: method]){// Rtm 登录
            NSString* appId = arguments[@"rtm_appId"];
            NSString* token = arguments[@"rtm_token"];
            NSString* uId = arguments[@"rtm_uId"];
            [self setAppId:appId];
            
            // 这里在登录Rtm的时候，先退出登录，然后再登录。
            [[self getRtmEngine] logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
                [[self getRtmEngine] loginByToken:token user:uId completion:^(AgoraRtmLoginErrorCode errorCode) {
                    bool isOK = errorCode==AgoraRtmLoginErrorOk;
                    NSString* code=[NSString stringWithFormat:@"%ld",(long)errorCode];
                    NSDictionary* data = @{
                        @"code": code,
                        @"method":@"login",
                        @"message":isOK?@"登录成功":@"登录失败",
                    };
                    result(data);
                    NSLog(@"%@",data);
                    
                    if(isOK){
                        AgoraRtmMessage* message = [[AgoraRtmMessage alloc] init];
                        message.text = @"这是一条测试消息";
                        
                        // 在这里测试下 给安卓设备发送点对点消息。 我的用户id : 226312414021309890 李莹的用户id 196158141853881820
                        [[self getRtmEngine] sendMessage:message toPeer:@"196158141853881820" completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
                            NSLog(@"消息发送状态：%ld",errorCode);
                        }];
                    }
                    
                }];
            }];
            
        }else if([@"logout" isEqualToString: method]){// Rtm 退登
            [[self getRtmEngine] logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
                NSString* code = [NSString stringWithFormat:@"%ld",(long)errorCode];
                bool isOk = AgoraRtmLogoutErrorOk == errorCode;
                NSDictionary* data = @{
                    @"code": code,
                    @"method":@"logout",
                    @"message":isOk?@"退登成功":@"退登失败",
                };
                result(data);
                NSLog(@"%@",data);
            }];
            
        }else if([@"acceptRemoteInvitation" isEqualToString: method]){// Rtm 接受会议邀请
            [[self rtmCallKit] acceptRemoteInvitation:self.invitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
                NSString* code = [NSString stringWithFormat:@"%ld",(long)errorCode];
                bool isOk = AgoraRtmInvitationApiCallErrorOk == errorCode;
                NSDictionary* data = @{
                    @"code":code,
                    @"method":method,
                    @"message":isOk?@"接受邀请 -> 成功":@"接受邀请 -> 失败",
                };
                self.rtmEventStreamHandler.eventSink(data);
                NSLog(@"%@",data);
            }];
            
        }else if([@"refuseRemoteInvitation" isEqualToString: method]){// Rtm 拒绝会议邀请
            [[self rtmCallKit] refuseRemoteInvitation:self.invitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
                NSString* code = [NSString stringWithFormat:@"%ld",(long)errorCode];
                bool isOk = AgoraRtmInvitationApiCallErrorOk == errorCode;
                NSDictionary* data = @{
                    @"code":code,
                    @"method":method,
                    @"message":isOk?@"拒绝会议邀请 -> 操作成功":@"拒绝会议邀请 -> 操作失败",
                };
                self.rtmEventStreamHandler.eventSink(data);
                NSLog(@"%@",data);
            }];
            
        } else{
            result(FlutterMethodNotImplemented);
        }
    };
}

/**
 * 收到Remote发起的 音视频会议邀请
 */
- (void)rtmCallKit:(AgoraRtmCallKit *)callKit remoteInvitationReceived:(AgoraRtmRemoteInvitation *)remoteInvitation{
    NSLog(@"remoteInvitationReceived：%@",remoteInvitation.callerId);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.invitation = remoteInvitation;
        NSDictionary* data = [self invitationToJson:remoteInvitation :0];
        self.rtmEventMsgStreamHandler.eventSink(data);
    });
}

/**
 * 发起方 已取消呼叫邀请
 */
- (void)rtmCallKit:(AgoraRtmCallKit *)callKit remoteInvitationCanceled:(AgoraRtmRemoteInvitation *)remoteInvitation{
    NSLog(@"remoteInvitationCanceled：%@",remoteInvitation.callerId);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.invitation = remoteInvitation;
        NSDictionary* data = [self invitationToJson:remoteInvitation :false];
        self.rtmEventMsgStreamHandler.eventSink(data);
    });
}

/**
 * 会议邀请失败：通常是由于以下两种情况：
 * 1. 发起邀请的一方 在对方接受邀请之前 挂断了
 * 2. 被邀请方60s内没有接受邀请，触发SDK的超时，自动回调此函数。
 * 此刻，可以认为是会议邀请结束了，本地可以主动挂断了。
 */
- (void)rtmCallKit:(AgoraRtmCallKit *)callKit remoteInvitationfailure:(AgoraRtmRemoteInvitation *)remoteInvitation{
    NSLog(@"remoteInvitationfailure：%@",remoteInvitation.callerId);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.invitation = remoteInvitation;
        NSDictionary* data = [self invitationToJson:remoteInvitation :false];
        self.rtmEventMsgStreamHandler.eventSink(data);
    });
}

/**
 * 收到Rtm 文本消息。
 */
- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"messageReceived：%@",message.text);
        NSDictionary* data = [self messageToJson:message];
        self.rtmEventMsgStreamHandler.eventSink(data);
    });
}

/**
 * 将RemoteInvitation转为json格式的数据
 */
- (NSDictionary*) invitationToJson : (nonnull AgoraRtmRemoteInvitation*) remoteInvitation : (bool*) isInvite{
    return @{
        @"status" : @YES,
        @"event_type" : @"invitation",
        @"data":@{
            @"callerId":remoteInvitation.callerId,
            @"channelId":remoteInvitation.channelId,
            @"content":remoteInvitation.content,
            @"response":remoteInvitation.response,
            @"state":@(remoteInvitation.state),
        },
    };
}

/**
 * 将AgoraRtmMessage转为json格式的数据
 */
- (NSDictionary*) messageToJson : (nonnull AgoraRtmMessage*)  message{
    return @{
        @"messageType" : @"text",
        @"data":@{
            @"messageType":@(message.type),
            @"text":message.text,
            @"isOfflineMessage":@(message.isOfflineMessage),
            @"serverReceivedTs":@(message.serverReceivedTs),
        },
    };
}

@end
