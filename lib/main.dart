import 'package:channel_test/alert.dart';
import 'package:channel_test/constants.dart';
import 'package:channel_test/plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('samples.flutter.dev/battery');

  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('获取手机电量🔋'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _login,
              child: const Text('登录'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('退出登录'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _accept,
              child: const Text('接受邀请'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _refuse,
              child: const Text('拒绝邀请'),
            ),
            const SizedBox(height: 56),
            Text(_batteryLevel),
          ],
        ),
      ),
    );
  }

  /// Rtm 登录
  void _login() async {
    var result = await rtmLogin(
      appId: Agora_Web_AppId,
      rtmToken: Agora_Token,
      rtmUid: Agora_Uid,
    );
    snackBarOk(result.toString());
  }

  /// Rtm 退出登录
  void _logout() async {
    var result = await rtmLogout();
    snackBarOk(result.toString());
  }

  /// Rtm 接受会议邀请
  void _accept() {
    acceptRemoteInvitation();
  }

  /// 拒绝邀请
  void _refuse() {
    refuseRemoteInvitation();
  }

  @override
  void initState() {
    super.initState();
    rtmEventChannel.receiveBroadcastStream().listen((event) {
      snackBarOk('Rtm EventChannel : ${event.toString()} ');
    });
    rtmMsgEventChannel.receiveBroadcastStream().listen((event) {
      snackBarOk('Rtm Message EventChannel : ${event.toString()} ');
    });
  }
}
