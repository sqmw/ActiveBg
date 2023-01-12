import "dart:io";
import 'dart:convert';

import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/TranslucentTBUtil.dart';

import 'FileDirUtil.dart' as file_dir_util show getPathFromIndex;

Map<String,dynamic> _config = {};

File getConfigFile(){
  // 这个config是发行时候的，对应utils包里面的
  File configFile = File("./config.json");
  if(configFile.existsSync()){
    return configFile;
  }else{
    // 返回调试的config，对应的是test包里面的，需要自己进行修改
    return File("test/config.json");
  }
}

/// config文件是在软件发布的时候使用，而配置好不需要修改
/// 这个函数仅仅运行一次，正常情况下config文件是有的
Future<void> loadConfig() async {
  File configFile = getConfigFile();
  String configStr = "";
  // 正常情况不需要这个if语句
  if(configFile.existsSync()){
    configStr = configFile.readAsStringSync();
    _config = json.decode(configStr);
    //${file_dir.getPathFromIndex(Directory("").absolute.path, 0)}/assets
    if(_config["BATH_PATH"].startsWith("./")){
      DataUtil.BATH_PATH = "${file_dir_util.getPathFromIndex(Directory("").absolute.path, 0)}/assets";
    }else{
      if(_config["BATH_PATH"].startsWith("lib")){
        DataUtil.BATH_PATH = "${file_dir_util.getPathFromIndex(Directory("").absolute.path, 0)}/${_config["BATH_PATH"]}";
      }else{
        DataUtil.BATH_PATH = _config["BATH_PATH"];
      }
    }
    DataUtil.ACTIVE_WEB_BG_PATH =  _config["ACTIVE_WEB_BG_PATH"];
    DataUtil.dynamicBgUrl = _config["dynamicBgUrl"];
    TranslucentTBUtil.translucentTBPath = _config["translucentTBPath"];
    DataUtil.dllLibPath = _config["dllLibPath"];
  }
}

Future<void> saveConfig() async {
  File configFile = getConfigFile();
  _config["BATH_PATH"] = DataUtil.BATH_PATH;
  _config["ACTIVE_WEB_BG_PATH"] = DataUtil.ACTIVE_WEB_BG_PATH;
  _config["dynamicBgUrl"] = DataUtil.dynamicBgUrl;
  _config["translucentTBPath"] = TranslucentTBUtil.translucentTBPath;
  _config["dllLibPath"] = DataUtil.dllLibPath;
  IOSink ioSink = configFile.openWrite();
  ioSink.write(json.encode(_config));
  await ioSink.flush();
  await ioSink.close();
  // Future.microtask(()async{
  //   await ioSink.done;
  //   ioSink.close();
  // });
}

/// 初始化运行使用的config文件
void init(){
  File configFile = File("./config.json");
  if(!configFile.existsSync()){
    configFile.createSync();
    configFile.writeAsString("""
{
  "BATH_PATH": "./assets",
  "ACTIVE_WEB_BG_PATH": "../active-bg-web/active_web_bg.exe",
  "dynamicBgUrl": "https://img-baofun.zhhainiao.com/pcwallpaper_ugc/preview/101d3f1af19562aa17ed65790c04c1b0_preview.mp4",
  "translucentTBPath": "../TranslucentTB/TranslucentTB.exe",
  "dllLibPath": "../dll"
}
  """);
  }
}