import 'dart:ffi';
import 'dart:developer';

import 'package:active_bg/component/HomeMain/HomeMain.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:active_bg/utils/ConfigUtil.dart' as config;

import 'package:win32/win32.dart';

import '../utils/Win32Util.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    /// 未添加 GestureDetector
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: "ActiveBackground",
    //   theme: ThemeData(
    //     appBarTheme: const AppBarTheme(
    //       backgroundColor: Color.fromRGBO(155, 154, 154, 1.0),
    //     ),
    //     primarySwatch: Colors.deepPurple,
    //   ),
    //   home: const HomeMain(),
    // );

    /// 添加了 GestureDetector
    return GestureDetector(
      /// 表示的是点下去的时候
      onTapDown: (_){
        /// 移动窗口
        Pointer<RECT> pRect = malloc<RECT>();
        GetWindowRect(Win32Util.hWndActiveBg, pRect);
        Win32Util.moveActiveBgWindow();
      },
      /// 计划自定义的窗口缩放在这里实现
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "ActiveBackground",
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromRGBO(155, 154, 154, 1.0),
          ),
          primarySwatch: Colors.deepPurple,
        ),
        home: const HomeMain(),
      ),
      /// 添加了鼠标进入等用来实现窗口缩放
      // child: MouseRegion(
      //   /// 通过这个事件实现窗口的缩放
      //   onHover: (PointerHoverEvent event){
      //     log("${event.localPosition}");
      //     //SystemMouseCursors.resizeUp;
      //     SetCursor(LoadCursor(GWL_HINSTANCE,TEXT("IDC_CROSS")));
      //   },
      //   child: MaterialApp(
      //     debugShowCheckedModeBanner: false,
      //     title: "ActiveBackground",
      //     theme: ThemeData(
      //       appBarTheme: const AppBarTheme(
      //         backgroundColor: Color.fromRGBO(155, 154, 154, 1.0),
      //       ),
      //       primarySwatch: Colors.deepPurple,
      //     ),
      //     home: const HomeMain(),
      //   ),
      // ),
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
    // config.loadConfig();
  }
}
