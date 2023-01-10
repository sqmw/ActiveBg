import "dart:io";
import 'dart:convert';

import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/TranslucentTBUtil.dart';

late final Map<String,dynamic> config;
void loadConfig(){
  File configFile = File("./config.json");
  String configStr;
  //判断文件是否存在
  if(configFile.existsSync()){
    configStr = configFile.readAsStringSync();
    config = json.decode(configStr);
    DataUtil.BATH_PATH = config["BATH_PATH"];
    print(DataUtil.BATH_PATH);
    DataUtil.ACTIVE_WEB_BG_PATH =  config["ACTIVE_WEB_BG_PATH"];
    DataUtil.dynamicBgUrl = config["dynamicBgUrl"];
    TranslucentTBUtil.translucentTBPath = config["translucentTBPath"];
    DataUtil.dllLibPath = config["dllLibPath"];
  }
}

void saveConfig(){
  File configFile = File("./config.json");
  config["BATH_PATH"] = DataUtil.BATH_PATH;
  config["ACTIVE_WEB_BG_PATH"] = DataUtil.BATH_PATH;
  config["dynamicBgUrl"] = DataUtil.dynamicBgUrl;
  config["translucentTBPath"] = TranslucentTBUtil.translucentTBPath;
  config["dllLibPath"] = DataUtil.dllLibPath;
  configFile.writeAsString(json.encode(config));
}