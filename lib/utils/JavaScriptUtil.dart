import 'dart:io';

import 'DataUtil.dart';
///
/// javascript 我们并不能通过编程的形式实现停止某一段代码：{
///   只能是自己设计标记等一些不好用的方法，并且不能获取当前chromium当前执行的代码，所以最好的办法就是重新载入
/// }
///
///
/// 规定，每个js subJoin的代码代码，只能有一个canvas
/// 在动态壁纸的代码里面最多只能有一个 canvas, 鼠标点击的只能是在canvas里面

/// classification of js documents
/// 1. script.js
/// run to handle dom
/// 2. img
/// use js to handle special_img
/// 3. subJoin
/// use js to get special effect
/// mouseClickParticle_click.js

String reloadHtml = "location.reload()";
const videoId = "active-bg-video";
String removeElement(String id){
  return 'document.getElementById("$id")?.remove()';
}
/// 设置视屏音量
String setVolumeOfVideo(double val){
  return 'document.querySelector("video").volume = $val';
}

String addVideoDom = 'let v = document.createElement("video");v.setAttribute("id","active-bg-video");v.setAttribute("class","full");v.setAttribute("fullscreen","true");v.setAttribute("style","width: 100%;height:100%;z-index: -1");document.body.appendChild(v)';

/// 表示的是将我们其他轻量级的js代码覆盖写入到我们script.js里面
/// script.js is run to handle dom
bool rewriteJavaScript(String script){
  try{
    getFileOfScriptJs().writeAsStringSync(script);
  }catch(e){
    return false;
  }
  return true;
}

/// "script.js":{           // 文件的名字，含拓展名
///   "name":"script",      // 展示出来的名字
///   "createDomId":"null"  // 改脚本创建的dom的id
/// },
class ScriptInfo{
  final String fileName;
  final String fileRelativePath;
  final bool isImg;
  final String showName;

  const ScriptInfo({required this.fileRelativePath,required this.fileName, required this.isImg, required this.showName});
}

/// script.js 这个文件是交换使用的，位置不会发生变化，不需要进行管理
Future<List<ScriptInfo>> getLocalScriptInfo()async{
  final List<ScriptInfo> scriptList = [];
  Directory imgFileScripts = Directory("${DataUtil.BASE_PATH}/script/img");
  Directory subJoinScripts = Directory("${DataUtil.BASE_PATH}/script/subJoin");
  var imgL = await imgFileScripts.list().toList();
  for (var element in imgL) {
    scriptList.add(ScriptInfo(fileRelativePath: "/img/${element.path.split(RegExp(r"[/|\\]")).last}", fileName: element.path.split(RegExp(r"[/|\\]")).last, isImg: true, showName: element.path.split(RegExp(r"[/|\\]")).last));
  }

  var subJoinL = await subJoinScripts.list().toList();
  for (var element in subJoinL) {
    scriptList.add(ScriptInfo(fileRelativePath: "/subJoin/${element.path.split(RegExp(r"[/|\\]")).last}", fileName: element.path.split(RegExp(r"[/|\\]")).last, isImg: false, showName: element.path.split(RegExp(r"[/|\\]")).last));
  }
  return scriptList;
}

/// 获取script.js 引用
File getFileOfScriptJs(){
  return File("${DataUtil.BASE_PATH}/script/script.js");
}