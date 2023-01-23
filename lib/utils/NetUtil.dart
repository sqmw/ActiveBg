import 'dart:async';
import 'dart:io';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:dio/dio.dart';

const minImgLinkLength = 20;
const maxImgLinkLength = 200;

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

const Duration timeStopRecurseOfGetLink = Duration(seconds: 20);
/// 递归实现得到 link
Future<List<String>> recurseToGetLink({required String url})async{
  List<String> list = [];
  List<String> temp = [];
  bool canStopRecurse = false;
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
  Future.microtask((){
    recurse(url);
  });
  /// 设置退出时间
  Timer(timeStopRecurseOfGetLink,(){
    canStopRecurse = true;
  });
  return list;
}

Future<List<String>> getNetImageFromHtmlUrl({String url = "https://bing.ioliu.cn/"})async{
  var res = await DataUtil.dio.get(url);
  var list = getLinkListByRegExp(res.data);
  list.removeWhere((element) => !element.contains(RegExp(r"(png|jpg)")) || element.length <= minImgLinkLength || element.length >= maxImgLinkLength );
  return list;
}
