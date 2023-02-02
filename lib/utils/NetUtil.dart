import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/Win32Util.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ffi';
import 'dart:collection';

import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';
import 'package:dio/dio.dart';

const minImgLinkLength = 20;
const maxImgLinkLength = 200;

///  backend response
///  regular activeDynamicBg communication format as follows
///  {
///    action: changeBg | executeScript | getImgFromVideo | mouseAction  ----> {changeBg: 0,executeScript:1, getImgFromVideo: 2}
///    data of each action
///      changeBg: url,
///      executeScript: script,
///      getImgFromVideo: ["url1","url2",...]
///      mouseAction: {
///        type: click | over | move,
///        /// 对 domId 进行了处理，如果没有找到对应的id的 dom 就直接对首个canvas进行操作
///        domId: xxx,
///        point: {
///          x: 0,
///          y: 0
///        }
///      }
///
///
///  }
///
/// fronted reqData
/// changeBg: none
/// executeScript: none
/// getImgFromVideo: return the img char stream encoded base64
/// {
///   type: -1 -> rest  0 -> imgBase64
///   data: ""
/// }
///
/// data: imgBase64 -> data = {index:?, base64}
///
/// 约定：取消设置 special_img 和 video 的时候，直接最开始的样式就行

class ResponseActions{
  /// 表示的是休息的状态
  static const rest = -1;
  static const  changeBg = 0;
  static const executeScript = 1;
  static const getImgFromVideo = 2;
  /// 鼠标的行为
  /// data:
  ///  {
  ///     type: click | over | move,
  ///     /// 对 domId 进行了处理，如果没有找到对应的id的 dom 就直接对首个canvas进行操作
  ///     domId: xxx,
  ///     point: {
  ///       x: 0,
  ///       y: 0
  ///     }
  ///  }
  ///  方便进行或运算
  static const mouseAction = 3, mouseActionClick = 1, mouseActionOver  = 2, mouseActionMove = 4;
  /// 表示的是文件拓展名后面是否包含
  static const strClick = "click", strOver = "over", strMove = "move";
}

class ReqType{
  /// 因为 每个100毫秒就会发起一次请求，防止backend浪费资源
  static const reqRest = -1;
  static const imageBase64 = 0;
}
/// 用来记录动态壁纸的展示的重要信息
/// 因为不会主动释放，所以需要我们自己主动 refresh
/// 实际上video和img都是二选一的，设置其中的一个的时候必须置空另外一个，目前设想的是视屏额外只能添加一个特效，图片类型的本身外可以再加一个特效
class ActiveDynamicBgVideoInfo{
  /// 表示的是我们的视频来自什么地方，如果是本地的话，需要一定的特殊处理
  /// static bool fromNet = true; // 可以通过路径直接进行判断
  /// 表示的是我们的视频的路径，用于自启动使用
  static String urlOrPath = "";
}

/// 这个表示的具有特效静态壁纸
class ActiveDynamicBgSpecialImgInfo{
  /// 表示的是当前的特效壁纸
  static String specialImgFileName = "";
  static String specialImgRelativePath = "";
}

/// 管理当前附加的脚本
/// 时刻维护是否有脚本，为空的时候就是没有
class SpecialSubjoin{
  /// 表示的是当前添加的附加脚本的数量
  static String scriptSubJoinFileName = "";
  static String scriptSubJoinRelativePath = "";
}

class Data{
  static ReceivePort? _recurseGetLinkListReceivePort;
  static late ReceivePort _base64ReceivePort;
  static late SendPort _base64SendPort;

  static ReceivePort? get recurseGetLinkListReceivePort =>
      _recurseGetLinkListReceivePort;

  static set recurseGetLinkListReceivePort(ReceivePort? value) {
    _recurseGetLinkListReceivePort = value;
  }

  static ReceivePort get base64ReceivePort => _base64ReceivePort;

  static set base64ReceivePort(ReceivePort value) {
    _base64ReceivePort = value;
    /// 因为可能有网速的原因，设置超时的时间为 60 seconds
    Timer(const Duration(minutes: 4),(){
      _base64ReceivePort.close();
    });
    _base64SendPort = _base64ReceivePort.sendPort;
  }

  /// sendPort只能获取，不能通过外界设置
  static SendPort get base64SendPort => _base64SendPort;

  /// 通信传输的信息
  static final Map<String, dynamic> _communicationMsg = {};

  static Map<String, dynamic> get communicationMsg => _communicationMsg;
  /// set 只能是自己设置了
  ///
  /// 设置执行脚本例子，这里的data是给浏览器，告诉浏览器他的需要执行的脚本的名字
  /// setCommunicationMsg(action: ResponseActions.executeScript , data: XXXScript)
  /// 表示的是执行了XXXScript这个脚本，之后会把文件放在服务器端口
  ///
  /// setCommunicationMsg(action: ResponseActions.mouseAction, data: {
  ///   type: ResponseActions.mouseActionClick | mouseActionOver | mouseActionMove
  ///   domId: xxx,  // 表示操作的 特效的鼠标作用的DOM的ID
  ///   point: {
  ///     x: 0,
  ///     y: 0
  ///   }
  /// })
  static void setCommunicationMsg({required int action, required dynamic data}){
    _communicationMsg["action"] = action;
    _communicationMsg["data"] = data;
  }

  /// 表示当前的执行脚本的相对路径
  static String? scriptFileRelativePath;
}

/// 用来处理和浏览器交互的communication
class CommunicationTaskQueueLoop{
  static final Queue<Map<String, dynamic>> _communicationTaskQueue = Queue();
  /// doBefore 需要在处理前调用
  static void addMsg({required int action, required dynamic data,required void Function() doBefore}){
    _communicationTaskQueue.add({
      "action":action,
      "data":data,
      "doBefore":doBefore
    });
  }
}

/// 交互的核心
void handleHttpRequestTask(){
  Future.microtask(() async {
    Map<String, dynamic>? msg;
    /// 版本2通过httpServer实现的
    HttpServer httpServer = await HttpServer.bind("localhost", DataUtil.portBridgeOfBg);
    var str = "";
    await for(HttpRequest httpRequest in httpServer){
      /// 表示的是请求script
      if(httpRequest.requestedUri.path.contains("script")){
        str = String.fromCharCodes((await File("${DataUtil.BASE_PATH}/script${Data.scriptFileRelativePath}").openRead().toList())[0]);
        httpRequest.response
          ..headers.set("Content-Type", "application/javascript") // Content-Type: application/javascript
          ..headers.set("Access-Control-Allow-Origin", "*")
          ..write(str)
          ..close();
      }else{
        var reqBody = await utf8.decoder.bind(httpRequest).join();
        var obj = json.decode(reqBody);
        switch(obj["type"]){
          case ReqType.reqRest:{
            break;
          }
        /// 表示fronted发来了base64图片
          case ReqType.imageBase64:{
            Data.base64SendPort.send(obj["data"]);
            break;
          }
        }
        httpRequest.response
          ..write (json.encode(
            Data.communicationMsg
          ))
          ..close();
      }
      /// 处理完上一个消息之后从 msg 队列里面获取msg知道msgQueue为空
      if(CommunicationTaskQueueLoop._communicationTaskQueue.isEmpty){
        Data.setCommunicationMsg(action: ResponseActions.rest, data: "");
      }else{
        msg = CommunicationTaskQueueLoop._communicationTaskQueue.removeFirst();
        msg["doBefore"]();
        Data.setCommunicationMsg(action: msg["action"], data: msg["data"]);
      }
    }
  });
}

/// 用来判断是否有网络
Future<bool?> isNetConnecting()async{
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  }on SocketException catch (_) {
    return false;
  }
  return null;
}

/// 用来判定某个端口是否被占用，返回的为端口号，-1表示被占用
/// port为0的时候会随机返回一个没用过的port
Future<int> getUnusedPort(int initPort)async {
  int port;
  ServerSocket serverSocket;
  try{
    serverSocket = await ServerSocket.bind("localhost", initPort);
    port = serverSocket.port;
    await serverSocket.close();
  }on Exception{
    port = -1;
  }
  return  port;
}

/// 匹配链接的 regex
RegExp linkRegExp =  RegExp(r'(https?|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]');

/// 这个里面的链接都是坑，不能访问
List<String> unreachableWebsite = [
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
];

/// 正则匹配链接，返回 list
List<String> getLinkListByRegExp(String source){
  List<String> linkList = [];
  linkRegExp.allMatches(source).forEach((element) {
    linkList.add(element[0]!);
  });
  return linkList;
}

const Duration timeStopRecurseOfGetLink = Duration(seconds: 15);

/// 递归实现得到 link
/// sendPort.send({"canClose":true, "list": list});
/// recurseToGetLink(url: "https://bizhi.cheetahfun.com/dn/pd163859.html", sendPort: receivePort.sendPort);
///   receivePort.listen((message) {
///     if(message["canClose"]){
///       receivePort.close();
///     }
///     print("${DateTime.now().second - startTime}   ${message.length}");
/// });
Future<void> recurseToGetLink({required String url,required SendPort sendPort, Duration timeStopRecurse = timeStopRecurseOfGetLink})async{
  Isolate.spawn((sendPort) {
    List<String> list = [];
    List<String> temp = [];
    bool canStopRecurse = false;
    /// 设置退出时间，防止递归不能结束
    Timer(timeStopRecurse,(){
      canStopRecurse = true;
    });
    /// 内部函数
    void recurse(String link)async{
      if(canStopRecurse){
        return;
      }
      Response res;
      try{
        res = await DataUtil.dio.get(link);
        temp = getLinkListByRegExp("${res.data}");
      } catch (e) {
        return;
      }
      if(temp.isNotEmpty){
        for (var subLink in temp){
          /// 防止递归无穷无尽
          if(list.contains(subLink) || unreachableWebsite.contains(subLink)){
            continue;
          }
          list.add(subLink);
          recurse(subLink);
        }
      }
    }
    recurse(url);
    int listLenBefore = -1;
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if(list.length == listLenBefore && canStopRecurse){
        /// 表示可以关闭 receivePort 了
        sendPort.send({"canClose":true, "list": list});
        timer.cancel();
      }
      sendPort.send({"canClose":false, "list": list});
      listLenBefore = list.length;
    });
  }, sendPort);
}

Future<List<String>> getNetImageFromHtmlUrl({String url = "https://bing.ioliu.cn/"})async{
  var res = await DataUtil.dio.get(url);
  var list = getLinkListByRegExp(res.data);
  list.removeWhere((element) => !element.contains(RegExp(r"(png|jpg)")) || element.length <= minImgLinkLength || element.length >= maxImgLinkLength );
  return list;
}

class MouseAction{
  static Pointer<POINT> pPointNew = malloc<POINT>(1);
  static Pointer<POINT> pPointOld = malloc<POINT>(1);
  static Timer? _timer;
  static bool pointUpdated = false;
  static stopMouseAction(){
    _timer?.cancel();
  }
  static int getMouseAction(String scriptName){
    if(scriptName.contains(ResponseActions.strClick) &&
      scriptName.contains(ResponseActions.strOver) &&
      scriptName.contains(ResponseActions.strMove)){
      return ResponseActions.mouseActionClick | ResponseActions.mouseActionMove | ResponseActions.mouseActionOver;
    }else if(
      scriptName.contains(ResponseActions.strClick) &&
      scriptName.contains(ResponseActions.strOver)){
      return ResponseActions.mouseActionClick | ResponseActions.mouseActionOver;
    }else if(
      scriptName.contains(ResponseActions.strClick) &&
      scriptName.contains(ResponseActions.strMove)){
      return ResponseActions.mouseActionClick | ResponseActions.mouseActionMove ;
    }else if(
      scriptName.contains(ResponseActions.strOver) &&
      scriptName.contains(ResponseActions.strMove)){
      return ResponseActions.mouseActionMove | ResponseActions.mouseActionOver;
    }else if(scriptName.contains(ResponseActions.strClick)){
      return ResponseActions.mouseActionClick;
    }else if(scriptName.contains(ResponseActions.strOver)){
      return ResponseActions.mouseActionOver;
    } else if(scriptName.contains(ResponseActions.strMove)){
      return ResponseActions.mouseActionMove;
    }
    return -1;
  }
  /// 默认情况下是包含了所有
  /// click为主要，其次是over，最后是move
  static void startMouseAction({int actionType = ResponseActions.mouseActionClick | ResponseActions.mouseActionMove | ResponseActions.mouseActionOver}){
    /// 这里应该需要钩子才能实现，目前的方法在其他浏览器上面试了可以，但是在tauri都不行
    return;

    _timer?.cancel();
    /// 判断是否有click意外的其他动作
    if(actionType == ResponseActions.mouseActionClick | ResponseActions.mouseActionMove | ResponseActions.mouseActionOver){
      pointUpdated = true;
    }else if(actionType ==ResponseActions.mouseActionMove | ResponseActions.mouseActionOver){
      pointUpdated = true;
    }else if(actionType == ResponseActions.mouseActionClick  | ResponseActions.mouseActionOver){
      pointUpdated = true;
    }else if(actionType == ResponseActions.mouseActionClick | ResponseActions.mouseActionMove ){
      pointUpdated = true;
    }else if(actionType ==  ResponseActions.mouseActionOver){
      pointUpdated = true;
    }else if(actionType ==  ResponseActions.mouseActionMove ){
      pointUpdated = true;
    }
    if(pointUpdated){
      GetCursorPos(pPointNew);
    }
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      /// 判断鼠标是否点下
      if(GetAsyncKeyState(VK_LBUTTON) != 0){
        pointUpdated = true;
        GetCursorPos(pPointNew);
      }
      if(pointUpdated && (pPointOld.ref.x != pPointNew.ref.x || pPointOld.ref.y != pPointNew.ref.y)){
        /// 这个是方案一，通过http将鼠标信息传递给浏览器，让浏览器来触发事件
        /// 目前实现了：click over move
        /// 问题：因为浏览器鼠标点击识别的是clientX|Y但是我传递的是screenX|Y，导致了比例差，这个这个比例在不同分辨率的电脑下
        /// 难以确定是否相同
        // CommunicationTaskQueueLoop.addMsg(
        //     action: ResponseActions.mouseAction,
        //     data: {
        //       "type": actionType,
        //       "point":{
        //         "x":pointer.ref.x,
        //         "y":pointer.ref.y,
        //       }
        //     },
        //     doBefore: (){
        //       pointUpdated = false;
        //     }
        // );
        /// 这个是方案二，程序员通过UI直接传递Message给浏览器，浏览器自己处理，实现模拟，
        /// 目前浏览器端的事件是右键事件，左键似乎被阻止了（目前原因不明）
        /// 抑或通过win hook实现
        PostMessage(Win32Util.hWndActiveDynamicBg, WM_RBUTTONDOWN, 0, MAKELONG(pPointNew.ref.x, pPointNew.ref.y));
        PostMessage(Win32Util.hWndActiveDynamicBg, WM_RBUTTONUP, 0, MAKELONG(pPointNew.ref.x, pPointNew.ref.y));
        print("old:-> (${pPointOld.ref.x},${pPointOld.ref.y}); new -> (${pPointNew.ref.x},${pPointNew.ref.y})");
        pPointOld.ref.x = pPointNew.ref.x;
        pPointOld.ref.y = pPointNew.ref.y;
      }
    });
  }
}

void dynamicBgVideoDownload( {String videoUrl = "", String imgUrl = "",String imgType = "gif", String videoType = "mp4", void Function()? callBack, String? imgBase64}){
  int nowMicroseconds = DataUtil.getNowMicroseconds();
  if(videoUrl.isNotEmpty){
    DataUtil.dio.download(videoUrl, "${DataUtil.BASE_PATH}/videos/mp4/$nowMicroseconds.$videoType");
  }
  if(imgUrl.isNotEmpty){
    DataUtil.dio.download(imgUrl, "${DataUtil.BASE_PATH}/videos/cover/$nowMicroseconds.$imgType");
  }
  if(imgBase64 != null && imgBase64.isNotEmpty){
    File("${DataUtil.BASE_PATH}/videos/cover/$nowMicroseconds.$imgType").writeAsBytes(base64.decode(imgBase64));
  }
  if(callBack != null){
    callBack();
  }
}