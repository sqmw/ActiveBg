import 'dart:async';
import 'dart:isolate';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/Win32Util.dart';
import 'package:flutter/material.dart';
import 'component/MyApp.dart';

import 'package:active_bg/utils/ConfigUtil.dart' as config;
import 'package:active_bg/utils/NetUtil.dart' as net_util show handleHttpRequestTask, CommunicationTaskQueueLoop, ResponseActions, imageDirPath;

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
  runApp(const MyApp());
  Isolate.spawn(
    (message) {
      Win32Util.createWorkerW();
    },
    null
  );
  /// 加载配置，设置窗口的透明度，在程序最开始启动的时候就设置透明度，在 C++ 代码里面
  Future.microtask(()async{
    await config.loadConfig();
    Win32Util.setActiveBgTransparent(DataUtil.opacity.toInt());
    Win32Util.setActiveBgCenter();
  });
  /// 为了方便调试的时候使用，不然仅仅有if里面的就可以了
  Win32Util.updateActiveBgWebHWnd();
  if(Win32Util.hWndActiveDynamicBg == 0){
    DataUtil.startActiveBgDynamicBgProc();
  }
  /// 将config里面的配置的壁纸设置好
  Timer(const Duration(seconds: 1),(){
    DataUtil.setDynamicBgUrl(DataUtil.dynamicBgUrl);
  });
  /// 启动端口，进行通信，比较繁琐的task不应该放在main里面
  net_util.handleHttpRequestTask();
}
