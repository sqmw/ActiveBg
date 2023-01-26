import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ffi' as ffi;
import 'package:active_bg/utils/Win32Util.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ffi/ffi.dart';
import 'dart:developer' as developer;
import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html_dom;

import '../component/viewUtils/ImageView.dart';
import './FileDirUtil.dart' as file_dir show getPathFromIndex;
import 'ConfigUtil.dart' as config show saveConfig;
import 'NetUtil.dart' as net_util show getUnusedPort;
import 'package:active_bg/utils/NetUtil.dart' as net_util show Data, ResponseActions;

typedef ChangeBackgroundFFI = ffi.Void Function(ffi.Pointer<Utf8>);
typedef ChangeBackground = void Function(ffi.Pointer<Utf8>);
class DataUtil{
  // local 采用了动态端口号
  // static int portLocalDynamicBg = 23576;

  /// 端口号相关的信息
  /// 本地的动态壁纸(mp4)的服务器的端口号
  static const portBridgeOfBg = 4444;
  /// 用来表示UI的透明度
  static double opacity = 100;
  // 用来存储数据的基本路径，目前仅仅可能需要修改的配置属性就只有这个
  /// 这个位置在电脑上面运行之后就不能修改
  static String BASE_PATH = "";
  static String ACTIVE_WEB_BG_PATH = "F:\\language\\flutter\\active_web_bg\\build\\windows\\runner\\Release\\active_web_bg.exe";
  static String dllLibPath = "lib/dll";
  static final _dylib = ffi.DynamicLibrary.open("$dllLibPath/bg_01.dll");
  static final ChangeBackground _changeBackground = _dylib.lookup<ffi.NativeFunction<ChangeBackgroundFFI>>("changeBackground").asFunction();
  static final Dio dio = Dio();
  static const IMAGE_COUNT = 9;
  static const MAX_IMG_FIRST = 460;
  /// 动态壁纸的基地址
  static const DYNAMIC_BASE_URL = "https://bizhi.cheetahfun.com";
  /// pageLength 112
  static const DYNAMIC_PAGE_LENGTH = 112;
  static const DYNAMIC_IMG_SEARCH_COUNT = 24;
  static const DYNAMIC_IMG_CATEGORY_COUNT = 18;
  /// querySelectStr for dynamic bg
  static const QUERY_TYPE = "li ul>li>a";
  static const QUERY_VIDEO_PAGE_LIST = "section>ul>li>div>a";
  static const QUERY_VIDEO = "main video";
  static final Random _random = Random();
  /// 设置动态桌面的 标题
  static const activeDynamicBgTitle = "active_dynamic_bg";

  /// 现在壁纸的类型是动态的还是静态的
  /// 应该通过判断是否能够获取到相应的窗口的句柄来判定壁纸的状态
  static int getRandomInt({int max = MAX_IMG_FIRST}){
    return _random.nextInt(max);
  }

  static Color getRandomColor(){
    return Color.fromRGBO(getRandomInt(max: 256), getRandomInt(max: 256), getRandomInt(max: 256), 1);
  }

  static void changeStaticBackground(String imgPath){
    //isActiveBgNow = false;
    Win32Util.destroyActiveBgWin();
    //activeBgProcNowIsShow = false;
    _changeBackground(imgPath.toNativeUtf8());
  }

  static int getNowMicroseconds(){
    return DateTime.now().microsecondsSinceEpoch;
  }

  /// 返回一个ListTile
  //region
  static Future<ListTile> getImageListTile(BuildContext context, String imgUrl)async{
    return ListTile(
      onTap: (){
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context){
              return ImageView(
                image: Image(
                  image: NetworkImage(imgUrl),
                ),
              );
            });
      },
      title: Image(
        image: NetworkImage(imgUrl),
      ),
      subtitle: Row(
        children: [
          Expanded(
              child: TextButton(
                onPressed: () {
                  developer.log("下载");
                },
                child: const Text("下载"),
              )
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                int uniTimeId = DataUtil.getNowMicroseconds();
                String suffix = calImgSuffix(imgUrl);
                DataUtil.dio.download(imgUrl, "${DataUtil.BASE_PATH}/images/$uniTimeId$suffix")
                    .then((value){
                  Timer(const Duration(milliseconds: 10),(){
                    DataUtil.changeStaticBackground("${DataUtil.BASE_PATH}/images/$uniTimeId$suffix");
                  });
                });
              },
              child: const Text("设为壁纸"),
            )
          ),
        ],
      ),
    );
  }
 //endregion
  /// bing必须要一个headers
  //region
  static const BING_HEADERS = {
    //GET /images/async?q=%E5%A3%81%E7%BA%B8&first=150&count=35 HTTP/2
    "Host": "cn.bing.com",
    "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0",
    "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
    "Accept-Language":"zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
    //"Accept-Encoding": "gzip, deflate, br",//不注释将会乱码
    "Connection": "keep-alive",
    //"Cookie":"SUID=M; MUID=16729E95E1D46AB607968C18E0976BDF; MUIDB=16729E95E1D46AB607968C18E0976BDF; _EDGE_S=F=1&SID=10F7B51429496EFE317AA799280A6FBE; _EDGE_V=1; SRCHD=AF=NOFORM; SRCHUID=V=2&GUID=73EAB7A2216D49188E7EC92C2C4BF889&dmnchg=1; SRCHUSR=DOB=20230102; SRCHHPGUSR=SRCHLANG=zh-Hans; _SS=SID=10F7B51429496EFE317AA799280A6FBE",
    "Upgrade-Insecure-Requests": "1",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1"
  };

  /// dynamic 不需要headers
  static const DYNAMIC_HEADERS = {
    //GET /images/async?q=%E5%A3%81%E7%BA%B8&first=150&count=35 HTTP/2
    "Host": "bizhi.cheetahfun.com",
    "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0",
    "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
    "Accept-Language":"zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
    //"Accept-Encoding": "gzip, deflate, br",//不注释将会乱码
    "Connection": "keep-alive",
    //"Cookie":"709ca936-508c-4dcc-9412-e797e5300d32=%5Bobject%20Object%5D; Hm_lvt_de0b3793ab042c4233d9695522c5e2e6=1672911435; Hm_lpvt_de0b3793ab042c4233d9695522c5e2e6=1672930959; 636a1194-51b2-4360-8fc6-94f3941396cc=%5Bobject%20Object%5D; f8e3c231-96bf-4b14-84ca-cc09a787aac1=%5Bobject%20Object%5D; 304288e6-f0a9-4b2b-8a9d-5f0e46cdb156=%5Bobject%20Object%5D; c75451e6-e108-4bab-af09-e606049fdbe9=%5Bobject%20Object%5D; 32815fcb-f5ea-4770-bfe4-e2c8e7c555ad=%5Bobject%20Object%5D; dd21f174-0356-4c01-884b-906a0ba5aea7=%5Bobject%20Object%5D; 09f5e5ce-c9d9-4b44-acf0-923223cfc184=%5Bobject%20Object%5D; 8d95a63e-c36a-4b78-8594-b5835e3c629e=%5Bobject%20Object%5D; bc05bb09-b2f5-471e-a7f9-805a23c895fb=%5Bobject%20Object%5D; 7845c01e-9789-40f9-8c2e-782b4ab6e86e=%5Bobject%20Object%5D; 2b9fe8aa-f2ce-48d9-b3c9-9ac451debadc=%5Bobject%20Object%5D; b34d7c75-7fef-4f2e-8476-34382fb6da93=%5Bobject%20Object%5D; 5d155075-60b2-4052-92f1-4bcc0bc4ac8d=%5Bobject%20Object%5D; 8130fa75-8859-4969-8e9c-736cd50bbeec=%5Bobject%20Object%5D; 2a0242df-b4b4-448b-9fc3-f5a2229740b0=%5Bobject%20Object%5D",
    "Upgrade-Insecure-Requests": "1",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "If-None-Match": "20891-yX0pZj5MmPFxpVR0RQLj0ScZN/s",
    "TE": "trailers"
  };
  //endregion

  static Future<List<String>> getImgAbsUrls({required String ques, String? imgUrl,required int start,int count = 35})async{
    List<String> resList = [];
    dio.options.headers = BING_HEADERS;
    var res = await dio.get("https://cn.bing.com/images/async?q=${Uri.encodeFull(ques)}&first=$start&count=$count");
    html_dom.Document dom = html.parse("${res.data}");
    List<html_dom.Element?> aList = dom.querySelectorAll("div>a[m]");
    for (var value in aList) {
      resList.add(json.decode(value!.attributes["m"]!)["murl"]);
    }
    dio.options.headers={};
    return resList;
  }

  static List<html_dom.Element> getEleListFromStrBySelector(String htmlStr, String selector){
    html_dom.Document document = html.parse(htmlStr);
    return document.querySelectorAll(selector);
  }

  //region
  static const imgTypeList = [
    ".jpg",
    ".png",
    ".bmp",
    ".apng",
    ".avif",
    ".gif",
    ".jpeg",
    ".jfif",
    ".pjpeg",
    ".pjp",
    ".svg",
    ".tif",
    ".tiff",
    ".webp"
  ];
  //endregion

  static String calImgSuffix(String imgUrl){
    for(var item in imgTypeList){
      if(imgUrl.endsWith(item)){
        return item;
      }
    }
    return '.jpg';
  }

  static String dynamicBgUrl = "https://img-baofun.zhhainiao.com/pcwallpaper_ugc/preview/101d3f1af19562aa17ed65790c04c1b0_preview.mp4";


  /// 启动壁纸展示进程（这个进程可以是一个浏览器也可以是一个视频播放器）
  /// 使用浏览器的话，html5规范不允许自动播放又声音的视频，使用视频播放器的话可以，但是视频播放器的话，功能就少了点
  /// 在开启这个进程之后，需要将这个进程设置在workerW下面
  static bool startActiveBgDynamicBgProc(){
    // 需要判断当前的壁纸的类型
    Future.microtask(() async{
      // 这段代码其实没必要
      Win32Util.createWorkerW();
      Process.run(ACTIVE_WEB_BG_PATH, []);
      Timer.periodic(const Duration(milliseconds: 300), (timer) {
        if (Win32Util.setActiveBgToParentWorkerW()){
          timer.cancel();
        }
      });
    });
    return true;
  }

  /// 通过端口来设置动态壁纸的地址,这个地址的类型可以是path，以及link等
  /// 这里需要判断此时是否是设置动态壁纸，用来启动active_web_bg进程
  /// 需要判断是不是来自本地的资源
  static Future<void> setDynamicBgUrl(String urlOrFilePath)async{
    Win32Util.updateActiveBgWebHWnd();
    // developer.log("web: ${Win32Util.hWndActiveWeb.toRadixString(16)}");
    if(Win32Util.hWndActiveDynamicBg == 0){
      startActiveBgDynamicBgProc();
    }
    /// 表示是netResource
    if(urlOrFilePath.startsWith("http")){
      /// 这里如果出现错误，检测不到
      dynamicBgUrl = urlOrFilePath;
    }else{
      /// 启动这个本地壁纸的线程
      int portLocalDynamicBg = await startLocalActiveBg(urlOrFilePath);
      dynamicBgUrl = "http://localhost:$portLocalDynamicBg?r=${getRandomInt(max: 10000)}";
    }

    ///设置需要返回的数据
    net_util.Data.setCommunicationMsg(action: net_util.ResponseActions.changeBg, data: dynamicBgUrl);

    Future.microtask((){
      config.saveConfig();
    });
  }

  /// C:/Users/19519/Desktop/videos/bg.mp4
  /// 开启一个返回视频的服务器
  static late HttpServer localActiveBgHttpServer;
  static Future<int> startLocalActiveBg(String path)async{
    // 没有被占用
    int portLocalDynamicBg;
    // if((portLocalDynamicBg = await net_util.getUnusedPort(0)) != -1);
    portLocalDynamicBg = await net_util.getUnusedPort(0);
    localActiveBgHttpServer = await HttpServer.bind("localhost", portLocalDynamicBg);
    File file = File(path);
    /// 通过测试，这个位置的代码也必须放在一个 future 任务里面
    Future.microtask(()async{
      HttpRequest httpRequest = await localActiveBgHttpServer.first;
      httpRequest.response
        ..headers.add("Content-Type", "video/mp4") /// 添加响应行
        ..write(String.fromCharCodes(file.readAsBytesSync())) /// String.fromCharCodes 不用的话返回的及时int的list [...]
        ..close();
    });
    return portLocalDynamicBg;
  }
}