import 'dart:async';
import "dart:io";
import 'dart:convert';

import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/TranslucentTBUtil.dart';

import 'FileDirUtil.dart' as file_dir_util show getPathFromIndex;

/// 这个文件用来进行配置的

/// 表示当前的壁纸类型（video | special_img）
class BgType{
  /// 这个表示的是初始状态，可以在配置文件进行读取
  static int type = -1;
  static const specialImg = 0;
  static const video = 1;
}
/// 部分配置文件在 DataUtil 里面
String imageDirPath = "";
/// 表示的是音量
double volume = 0;

Map<String,dynamic> _config = {};
bool configCanSave = true;
late Timer saveTimer;

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
    /// 表示的是在初始启动的情况下，通过base_path来判定是不是第一次启动
    if(_config["BATH_PATH"].startsWith("./")){
      DataUtil.BASE_PATH = "${file_dir_util.getPathFromIndex(Directory("").absolute.path, 0)}/assets";
      imageDirPath = "${DataUtil.BASE_PATH}/images";
    }else{
      if(_config["BATH_PATH"].startsWith("lib")){
        DataUtil.BASE_PATH = "${file_dir_util.getPathFromIndex(Directory("").absolute.path, 0)}/${_config["BATH_PATH"]}";
        imageDirPath = "${DataUtil.BASE_PATH}/images";
      }else{
        DataUtil.BASE_PATH = _config["BATH_PATH"];
        imageDirPath = _config["imageDirPath"];
      }
    }
    DataUtil.ACTIVE_WEB_BG_PATH =  _config["ACTIVE_WEB_BG_PATH"];
    DataUtil.dynamicBgUrl = _config["dynamicBgUrl"];
    TranslucentTBUtil.translucentTBPath = _config["translucentTBPath"];
    DataUtil.dllLibPath = _config["dllLibPath"];
    DataUtil.opacity = _config["opacity"].toDouble();
    volume = _config["volume"].toDouble();
  }
}

/// 应该放在一个 future 里面执行，这个需要做防抖
Future<void> saveConfig() async {
  if(configCanSave){
    configCanSave = false;
    File configFile = getConfigFile();
    _config["BATH_PATH"] = DataUtil.BASE_PATH;
    _config["ACTIVE_WEB_BG_PATH"] = DataUtil.ACTIVE_WEB_BG_PATH;
    _config["dynamicBgUrl"] = DataUtil.dynamicBgUrl;
    _config["translucentTBPath"] = TranslucentTBUtil.translucentTBPath;
    _config["dllLibPath"] = DataUtil.dllLibPath;
    _config["opacity"] = DataUtil.opacity;
    _config["volume"] = volume;
    _config["imageDirPath"] = imageDirPath;
    IOSink ioSink = configFile.openWrite();
    ioSink.write(json.encode(_config));
    await ioSink.flush();
    await ioSink.close();

    saveTimer = Timer(
      const Duration(microseconds: 500),(){
      configCanSave = true;
    });
  }
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

/// 配置文件
/**
 * {
    "BATH_PATH": "./assets",
    "ACTIVE_WEB_BG_PATH": "../active_dynamic_bg/active_dynamic_bg.exe",
    "dynamicBgUrl": "https://img-baofun.zhhainiao.com/pcwallpaper_ugc/preview/101d3f1af19562aa17ed65790c04c1b0_preview.mp4",
    "translucentTBPath": "../TranslucentTB/TranslucentTB.exe",
    "dllLibPath": "../dll",
    "isActiveNow": false,
    "volume": 0,
    "opacity": 200,
    "imageDirPath":"",
    "localImg": "",
    "localVideo": "",
    "dynamicBgType": "specialOfImg | video",
    "unreachableWebsite": [
    "duba.com",
    "ddooo.com",
    "51testing.com",
    "product.pchome.net",
    "http://www.ijinshan.com/",
    "https://www.liebao.cn/",
    "http://www.drivergenius.com/",
    "http://soft.duba.com/",
    "http://www.52hy.52pcfree.com/",
    "https://www.duba.com/"
    ]
    }
 */