import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html show parse;

import '../../../utils/DataUtil.dart';
import 'package:active_bg/component/utils/ImageView.dart';

class DynamicBg extends StatefulWidget {
  const DynamicBg({Key? key}) : super(key: key);

  @override
  State<DynamicBg> createState() => _DynamicBgState();
}

class _DynamicBgState extends State<DynamicBg> {
  late TextEditingController _keyTextController;
  late Size _size;
  late List<Widget> _classificationList = [];
  final List<Widget> _recommendDynamicBgList = [

  ];


  @override
  void initState() {
    super.initState();
    _keyTextController = TextEditingController();
    loadWidgetInfo();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        /// 搜索
        Center(
          child: SizedBox(
            width: _size.width * 0.8,
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                suffix: IconButton(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.search),
                )
              ),
              controller: _keyTextController,
            ),
          ),
        ),
        /// 推荐
        const Text("推荐",textAlign: TextAlign.center,),
        SizedBox(
          height: _size.height * 1,
          width: _size.width,
          child:GridView.count(
            childAspectRatio: 99/54,
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            children: _recommendDynamicBgList,
          ),
        ),
        /// 分类
        const Text("分类", textAlign: TextAlign.center,),
        SizedBox(
          width: _size.width,
          height: _size.width / 4 * 54/99 * (_classificationList.length / 4).ceil() + 100,
          child:GridView.count(
            childAspectRatio: 99/54,
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            children: _classificationList,
          ),
        ),
      ],
    );
  }

  Future<void> loadWidgetInfo() async{
    //DataUtil.dio.options.headers = DataUtil.DYNAMIC_HEADERS;
    var response = await DataUtil.dio.get("https://bizhi.cheetahfun.com/");
    //DataUtil.dio.options.headers = {};
    /// 获取推荐
    // region
    log("${response.data.toString().length}--->length");
    List<html_dom.Element> recommendListInfo = DataUtil.getDynamicBgUrlList("${response.data}", DataUtil.QUERY_VIDEO_PAGE_LIST);
    log("${recommendListInfo}");
    //print(element.innerHtml);
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
    List<html_dom.Element> classificationListInfo = DataUtil.getDynamicBgUrlList("${response.data}", DataUtil.QUERY_TYPE);
    for (var element in classificationListInfo) {
      _classificationList.add(ListTile(
        title: const Image(image: NetworkImage("https://tuapi.eees.cc/api.php?category=dongman&type=302")),
        subtitle: Text(element.text,textAlign: TextAlign.center,),
      ));
    }
  }
}
