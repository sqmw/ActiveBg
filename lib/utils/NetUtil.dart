import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:active_bg/utils/DataUtil.dart';
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

class ResponseActions{
  /// 表示的是休息的状态
  static const rest = -1;
  static const  changeBg = 0;
  static const executeScript = 1;
  static const getImgFromVideo = 2;
}

class ReqType{
  /// 因为 每个100毫秒就会发起一次请求，防止backend浪费资源
  static const reqRest = -1;
  static const imageBase64 = 0;
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
  static void setCommunicationMsg({required int action, required dynamic data}) {
    _communicationMsg["action"] = action;
    _communicationMsg["data"] = data;
  }
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
