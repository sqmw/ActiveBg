import 'dart:ui';
import 'package:active_bg/component/HomeMain/HomeMain.dart';
import 'package:flutter/material.dart';
import 'package:active_bg/utils/ConfigUtil.dart' as config;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ActiveBackground",
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(155, 154, 154, 1.0),
        ),
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeMain(),
    );
  }

  /// 这个函数可能没有执行，关闭整个程序和dispose不一样
  @override
  void dispose() {
    super.dispose();
    /// 保存配置文件
    // config.saveConfig();
  }

  @override
  void initState() {
    super.initState();
    config.loadConfig();
  }
}
