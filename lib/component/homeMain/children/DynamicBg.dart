import 'package:active_bg/component/dynamic/DynamicSearch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:html/dom.dart' as html_dom;

import '../../../utils/DataUtil.dart';
import 'package:active_bg/component/dynamic/RecommendAndClassifySet.dart';
import 'package:active_bg/component/viewUtils/ImageView.dart';

import '../../viewUtils/NetCheck.dart';

class DynamicBg extends StatefulWidget {
  const DynamicBg({Key? key}) : super(key: key);

  @override
  State<DynamicBg> createState() => _DynamicBgState();
}

class _DynamicBgState extends State<DynamicBg> {
  late TextEditingController _keyTextController;
  late Size _size;
  late final List<Widget> _classificationList = [];
  final List<Widget> _recommendDynamicBgList = [];

  @override
  void initState() {
    super.initState();
    _keyTextController = TextEditingController();
    loadWidgetInfo();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    // log("build");
    // log("${_classificationList.length}-->分类，${_recommendDynamicBgList.length}-->推荐");
    return NetCheck(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          /// 搜索
          Center(
            child: SizedBox(
              width: _size.width * 0.8,
              /// 搜索栏目的输入框以及搜索
              child: Row(
                children: [
                  Expanded(
                      flex:4,
                      /// 添加回车键搜索监听
                      child: RawKeyboardListener(
                        onKey: (RawKeyEvent rawKeyEvent){
                          if(rawKeyEvent.runtimeType == RawKeyDownEvent){
                            if(rawKeyEvent.data is RawKeyEventDataWindows ){
                              RawKeyEventDataWindows rawKeyEventDataWindows = rawKeyEvent.data as RawKeyEventDataWindows;
                              if(rawKeyEventDataWindows.logicalKey.keyId == LogicalKeyboardKey.enter.keyId){
                                search();
                              }
                            }
                          }
                        },
                        focusNode: FocusNode(),
                        child: TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                              hintText: "请输入搜索关键字",
                              suffix: IconButton(
                                onPressed: () {
                                  Navigator.push(context,MaterialPageRoute(builder: (context){
                                    return DynamicSearchSet("https://bizhi.cheetahfun.com/search.html?search=${Uri.encodeFull(_keyTextController.text)}&");
                                  }));
                                },
                                icon: const Icon(Icons.search),
                              )
                          ),
                          controller: _keyTextController,
                        ),
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: (){
                          search();
                        },
                        child: const Text("搜索"),
                      )
                  )
                ],
              ),
            ),
          ),
          /// 推荐和分类
          const RecommendAndClassifySet(),
        ],
      ),
    );
  }

  void loadWidgetInfo() async{
    //DataUtil.dio.options.headers = DataUtil.DYNAMIC_HEADERS;
    var response = await DataUtil.dio.get(DataUtil.DYNAMIC_BASE_URL);
    //DataUtil.dio.options.headers = {};
    /// 获取推荐
    // region
    // log("${response.data.toString().length}--->length");
    List<html_dom.Element> recommendListInfo = DataUtil.getEleListFromStrBySelector("${response.data}", DataUtil.QUERY_VIDEO_PAGE_LIST);
    /// log("${recommendListInfo}");
    /// print(element.innerHtml);
    for (var element in recommendListInfo) {
      _recommendDynamicBgList.add(ListTile(
        onTap: (){
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context){
                return ImageView(
                  image: Image(
                    fit: BoxFit.fill,
                    image: NetworkImage("${element.children[0].attributes["src"]}"),
                  ),
                );
              });
        },
        title: Image(
          image: NetworkImage("${element.children[0].attributes["src"]}"),
        ),
        subtitle: Row(
          children: [
            Expanded(
                child: TextButton(
                  onPressed: () {

                  },
                  child: const Text("预览"),
                )
            ),
            Expanded(
                child: TextButton(
                  onPressed: () {
                  },
                  child: const Text("设为壁纸"),
                )
            ),
          ],
        ),
      ));
    }
    //endregion
    /// 获取分类
    List<html_dom.Element> classificationListInfo = DataUtil.getEleListFromStrBySelector("${response.data}", DataUtil.QUERY_TYPE);
    for (var element in classificationListInfo) {
      _classificationList.add(ListTile(
        onTap: (){
          Navigator.push(context,MaterialPageRoute(builder: (context){
            return const DynamicSearchSet("");
          }));
        },
        title: const Image(image: NetworkImage("https://tuapi.eees.cc/api.php?category=dongman&type=302")),
        subtitle: Text(element.text,textAlign: TextAlign.center,),
      ));
    }
  }

  void search() {
    Navigator.push(context,MaterialPageRoute(builder: (context){
      return DynamicSearchSet("https://bizhi.cheetahfun.com/search.html?search=${Uri.encodeFull(_keyTextController.text)}&");
    }));
  }
}
