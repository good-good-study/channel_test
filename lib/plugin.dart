import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 处理RTM基本事件动作：RTM 登录、登出、前台服务。
const _rtmMethodChannel = MethodChannel('io.agora.rtm.channel');

/// 处理RTM接收到音视频邀请事件。
const rtmEventChannel = EventChannel('io.agora.rtm.event.channel');

/// 处理接收到的RTM云信令（实时消息）。
const rtmMsgEventChannel = EventChannel('io.agora.rtm.message.channel');

/// 登录 Agora RTM
Future<dynamic> rtmLogin({
  required String appId,
  required String rtmToken,
  required String rtmUid,
}) async {
  var result = await _rtmMethodChannel.invokeMethod(
    'login',
    {
      'rtm_appId': appId,
      'rtm_token': rtmToken,
      'rtm_uId': rtmUid,
    },
  );
  log('RtmLogin : $result');
  return result;
}

/// RTM 退出登录
Future<dynamic> rtmLogout() async {
  var result = await _rtmMethodChannel.invokeMethod('logout');
  log('RtmLogin : $result');
  return result;
}

/// RTM 接受邀请
Future<void> acceptRemoteInvitation() async {
  var result = await _rtmMethodChannel.invokeMethod('acceptRemoteInvitation');
  log('RtmLogin : $result');
}

/// RTM 拒绝邀请
Future<void> refuseRemoteInvitation() async {
  var result = await _rtmMethodChannel.invokeMethod('refuseRemoteInvitation');
  log('RtmLogin : $result');
}

/// 显示安卓端的前台服务。
Future<void> startForeground() async {
  if (!kIsWeb && (Platform.isAndroid || Platform.isFuchsia)) {
    var result = await _rtmMethodChannel.invokeMethod('startForeground');
    log('startForeground : $result');
  }
}

/// 移除安卓端的前台服务。
Future<void> stopForeground() async {
  if (!kIsWeb && (Platform.isAndroid || Platform.isFuchsia)) {
    _rtmMethodChannel.invokeMethod('stopForeground');
    log('stopForeground');
  }
}
