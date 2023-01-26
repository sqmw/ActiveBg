import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/Win32Util.dart';
import 'package:flutter/material.dart';
import 'component/MyApp.dart';

import 'package:active_bg/utils/ConfigUtil.dart' as config;
import 'package:active_bg/utils/NetUtil.dart' as net_util show Data, ResponseActions, ReqType;

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

  /// 加载配置，设置窗口的透明度，在程序最开始启动的时候就设置透明度，在 C++ 代码里面
  Future.microtask(()async{
    await config.loadConfig();
    Win32Util.setActiveBgTransparent(DataUtil.opacity.toInt());
    Win32Util.setActiveBgCenter();
  });

  /// 启动端口，进行通信
  Future.microtask(() async {
    /// 版本2通过httpServer实现的
    HttpServer httpServer = await HttpServer.bind("localhost", DataUtil.portBridgeOfBg);
    await for(HttpRequest httpRequest in httpServer){
      var reqBody = await utf8.decoder.bind(httpRequest).join();
      var obj = json.decode(reqBody);
      switch(obj["type"]){
        case net_util.ReqType.reqRest:{
          break;
        }
        /// 表示fronted发来了base64图片
        case net_util.ReqType.imageBase64:{
          net_util.Data.base64SendPort.send(obj["data"]);
          break;
        }
      }
      httpRequest.response
        ..write (json.encode(
          net_util.Data.communicationMsg
        ))
        ..close();
      /// 执行完之后就置空
      net_util.Data.setCommunicationMsg(action: net_util.ResponseActions.rest, data: "");
    }
  });
}
