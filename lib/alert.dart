import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const snackBarId = 1024;
const dialogId = 1025;

void snackBarOk(String? msg, {String? title}) {
  snackBar(msg, title: title, backgroundColor: Colors.greenAccent);
}

void snackBarError(String? msg, {String? title}) {
  snackBar(msg, title: title, isError: true);
}

/// [isError] ： 是否显示红色背景、白色文字
void snackBar(
  String? msg, {
  String? title,
  Duration? duration,
  Color? colorTitleText,
  Color? colorText,
  Color? backgroundColor,
  bool isError = false,
}) {
  if (msg == null) return;
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }
  Get.snackbar(
    '',
    msg,
    titleText: Text(
      title ?? '提示',
      style: TextStyle(
        color: isError ? Colors.white : colorTitleText ?? Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    barBlur: 24,
    backgroundColor: isError ? Colors.red : backgroundColor,
    colorText: isError ? Colors.white : colorText,
    duration: duration ?? const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 400),
    // android、ios 移动设备有状态栏的部分留出来，所以桌面设备需要单独空出来这部分。
    margin: kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux
        ? const EdgeInsets.all(16)
        : const EdgeInsets.symmetric(horizontal: 10),
  );
}
