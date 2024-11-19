import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'component/my_app.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 window_manager
  await windowManager.ensureInitialized();

  // 配置窗口属性
  WindowOptions windowOptions = const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden, // 隐藏标题栏
    alwaysOnTop: true,
    // 可以添加其他窗口配置，比如：
    size: Size(800, 600),
    // minimumSize: Size(400, 300),
    // center: true,
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}
