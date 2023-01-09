import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ffi' as ffi;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ffi/ffi.dart';
import 'dart:developer' as developer;
import 'package:html/parser.dart' as html show parse;
import 'package:html/dom.dart' as html_dom;

import '../component/utils/ImageView.dart';

typedef ChangeBackgroundFFI = ffi.Void Function(ffi.Pointer<Utf8>);
typedef ChangeBackground = void Function(ffi.Pointer<Utf8>);

class DataUtil{
  static const String BATH_PATH = "F:/language/flutter/ActiveBg/lib/assets";
  static final _dylib = ffi.DynamicLibrary.open("lib/dll/bg_01.dll");
  static final ChangeBackground changeBackground = _dylib.lookup<ffi.NativeFunction<ChangeBackgroundFFI>>("changeBackground").asFunction();
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
  /// 现在壁纸的类型是动态的还是静态的
  static bool isActiveBgNow = false;

  static int getRandomInt({int max = MAX_IMG_FIRST}){
    return _random.nextInt(max);
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
                DataUtil.dio.download(imgUrl, "${DataUtil.BATH_PATH}/image/${uniTimeId}${suffix}")
                    .then((value){
                  Timer(const Duration(milliseconds: 10),(){
                    DataUtil.changeBackground("${DataUtil.BATH_PATH}/image/${uniTimeId}$suffix".toNativeUtf8());
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
  static const IMG_TYPE_LIST = [
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
    for(var item in IMG_TYPE_LIST){
      if(imgUrl.endsWith(item)){
        return item;
      }
    }
    return '.jpg';
  }

  static String dynamicBgUrl = "https://img-baofun.zhhainiao.com/pcwallpaper_ugc/preview/101d3f1af19562aa17ed65790c04c1b0_preview.mp4";
  /// 通过端口来设置动态壁纸的地址
  static void setDynamicBgUrl(String url){
    dynamicBgUrl  = url;
  }
  /// 启动壁纸展示进程（这个进程可以是一个浏览器也可以是一个视频播放器）
  /// 使用浏览器的话，html5规范不允许自动播放又声音的视频，使用视频播放器的话可以，但是视频播放器的话，功能就少了点
  static bool startActiveBgWeb(){
    // 需要判断当前的壁纸的类型
    return true;
  }

  /// 将展示动态壁纸的窗口放在worderW下面
  static bool setActiveBgWndWebPos(){
    return true;
  }

  /// 创建workerW
  static void createWorkerW(){

  }
}

/**
 * 经过测试，不需要headers
 */

/// 动漫基地址 https://bizhi.cheetahfun.com/dn/c2d/
/// 动漫第二页 https://bizhi.cheetahfun.com/dn/c2d/p2
///
/// 风景      https://bizhi.cheetahfun.com/dn/c1d/p2
/// 科技      https://bizhi.cheetahfun.com/dn/c7d/
/// 搜索      https://bizhi.cheetahfun.com/search.html?search=%E5%8A%A8%E6%BC%AB&page=1
///
///
/// 获取种类  document.querySelectorAll("li ul>li>a")
/// 分类(/首页)/搜索获取链接  document.querySelectorAll("section>ul>li a")
/// 获取视频里面的父节点的孩子 document.querySelector("main video").parentElement.childNodes //cou=2
///
///
/// 国内可访问


/**
 * package:html 0.15.0 0.15.1 的 bug
 * querySelectorAll("section>ul>li>div>a")  ->得到结果
 * querySelectorAll("section>ul>li a")      ->什么都没有
 */