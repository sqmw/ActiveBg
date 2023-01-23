import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/Win32Util.dart';
import 'package:flutter/material.dart';
import 'component/MyApp.dart';

import 'package:active_bg/utils/ConfigUtil.dart' as config;

/// 调试的时候如果已经启动了 active_dynamic_bg，也是可以的
void main() async{
  /// 判定程序是否可以执行
  /// 服务器应该还有6个月过期

  // Future.microtask(() async {
  //   var res = await DataUtil.dio.get("http://43.142.129.53:6534/can-run${Platform.localHostname}");
  //   if(!json.decode(res.data)["canRun"]){
  //     exit(-1);
  //   }
  // });
  /// 创建WorkerW窗口，这里应该在建立一个如果现在设置的是动态壁纸就开启动态壁纸的逻辑
  Isolate.spawn(
    (message) {
      Win32Util.createWorkerW();
    },
    null
  );
  runApp(const MyApp());

  /// 加载配置，设置窗口的透明度，在程序最开始启动的时候就设置透明度，在C++代码里面
  Future.microtask(()async{
    await config.loadConfig();
    Win32Util.setActiveBgTransparent(DataUtil.opacity.toInt());
    Win32Util.setActiveBgCenter();
  });

  /// 启动端口，进行通信
  Future.microtask(() async {
    /// 这个是一个版本的
    // ServerSocket serverSocket = await ServerSocket.bind("localhost", 4444);
    // serverSocket.listen((Socket clientSocket) async {
    //   clientSocket.write(DataUtil.dynamicBgUrl);
    //   await clientSocket.flush();
    //   await clientSocket.close();
    // });
    /// 版本2通过httpServer实现的
    HttpServer httpServer = await HttpServer.bind("localhost", DataUtil.portBridgeOfBg);
    await for(HttpRequest httpRequest in httpServer){
      httpRequest.response
        ..write (json.encode({
          "type":1,
          "path":DataUtil.dynamicBgUrl
        }))
        ..close();
    }
  });
}
