import 'dart:io';
import 'dart:developer';
import 'package:active_bg/utils/ConfigUtil.dart';

import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/Win32Util.dart';
import 'package:flutter/material.dart';

import 'component/MyApp.dart';

void main() async{
  runApp(const MyApp());
  /// 启动端口，进行通信
  Future.microtask(() async {
    ServerSocket serverSocket = await ServerSocket.bind("localhost", 4444);
    serverSocket.listen((Socket clientSocket) async {
      clientSocket.write(DataUtil.dynamicBgUrl);
      await clientSocket.flush();
      await clientSocket.close();
    });
  });
  /// 创建WorkerW窗口
  Future.microtask((){
    Win32Util.createWorkerW();
  });
}
