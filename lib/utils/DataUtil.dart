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
  static final Random _random = Random();
  static int getRandomInt({int max = MAX_IMG_FIRST}){
    return _random.nextInt(max);
  }

  static int getNowMicroseconds(){
    return DateTime.now().microsecondsSinceEpoch;
  }

  /// 返回一个ListTile
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

  static String calImgSuffix(String imgUrl){
    for(var item in IMG_TYPE_LIST){
      if(imgUrl.endsWith(item)){
        return item;
      }
    }
    return '.jpg';
  }

}