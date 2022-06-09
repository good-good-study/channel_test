// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';

///定义一些Widget常量

///对话框宽度比例[基于屏幕宽度]
const double widthFactor = 0.866;

///appbarHeight
const double appbarHeight = 40.0;

///帖子、资讯默认图片的高度
const double mediaImageHeight = 196.0;

///[FadeInImage]淡入动画时长
const Duration fadeInDuration = Duration(milliseconds: 200);

///[FadeInImage]淡出动画时长
const Duration fadeOutDuration = Duration(milliseconds: 200);

/// 未避免页面导航过程中更新UI, 故在进行API请求前加入等待时间。
const delayed = Duration(milliseconds: 232);

/// i-sleep 使用说明书
const iSleep = "https://dolphin.izhaohu.com/portal/isleep/#/";

/// 用户协议
const protocol = 'https://dolphin.izhaohu.com/portal/user-policy.html';

/// 隐私政策
const privacy = 'https://dolphin.izhaohu.com/portal/privacy-policy.html';

/// 康复设备标签分类，自定义全部。
const tagAllUrl =
    'https://dolphin-open.oss-cn-shanghai.aliyuncs.com/book/tag/all.png';

/// 声网配置信息=============================START================================
///
const Agora_Web_AppId = "95b6a3ded8084f34a043d84e8dc1e49f"; // 用于web和app调试
const Agora_AppId = "e1921e0460bd478c8906ab8de3aeb34f"; // app 自己的调试。

const Agora_Channel = 'test_channel';
// 临时
const Agora_Token =
    '00695b6a3ded8084f34a043d84e8dc1e49fIAD2IShqy33hAryeSMe8C3/8iJTNYcfSbuuGfIu0gU+C7u6TnAYAAAAAEABUlG4DGcChYgEA6AO60UTF';
const Agora_Uid = "226312414021309890"; // 用户id 。

///
/// 声网配置信息=============================END==================================
