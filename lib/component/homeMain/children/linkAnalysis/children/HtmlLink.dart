import 'dart:async';
import 'dart:io';

import 'package:active_bg/component/homeMain/children/linkAnalysis/children/PageSwitchBar.dart';
import 'package:active_bg/component/homeMain/children/linkAnalysis/children/PageSwitchController.dart';
import 'package:active_bg/mixins/UriAnalysis.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/NetUtil.dart' as net_util show recurseToGetLink, timeStopRecurseOfGetLink;

class HtmlLink extends StatefulWidget {
  const HtmlLink({Key? key}) : super(key: key);

  @override
  State<HtmlLink> createState() => _HtmlLinkState();
}

class _HtmlLinkState extends State<HtmlLink> with UriAnalysis{
  late PageSwitchController _pageSwitchController;
  int _pageIndex = 0;
  late List<String> urlList;
  String _searchKey = "";


  @override
  void initState() {
    super.initState();
    _pageSwitchController = PageSwitchController();
  }

  @override
  Widget build(BuildContext context) {

    size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(size.width * 0.2, 0, size.width * 0.2, 0),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  /// 点击前往链接目的地
                  child: IconButton(
                    onPressed: ()async{
                      if(textEditingController.text.isEmpty){
                        return;
                      }
                      url_launcher.launchUrl(Uri.parse(textEditingController.text));
                    },
                    icon: Icon(Icons.call_made, color: Theme.of(context).primaryColor,),
                  )
              ),
              Expanded(
                  flex: 12,
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: "请输入链接"
                    ),
                    autofocus: true,
                    controller: textEditingController,
                  )
              ),
              Expanded(
                  flex: 3,
                  child: TextButton(
                    onPressed: () async {
                      if(textEditingController.text.isEmpty || textEditingController.text == _searchKey){
                        return;
                      }
                      _searchKey = textEditingController.text;
                      handleSearch();
                    },
                    child: const Text("搜索"),
                  )
              )
            ],
          ),
        ),
        Flexible(
          child: Container(
            // color: Colors.red,
            child: Stack(
              children: [
                Positioned(
                  right: size.width * 0.02,
                  top: 0,
                  child: PageSwitchBar(
                    pageSwitchController: _pageSwitchController,
                    /// 表示的是鼠标点击我们定义的事件的时候需要做的事情，这个函数有组件定义，但是组件的函数暴露在了父组件里面，可以实现通信
                    onPageIndexChange: (int index) {
                      setState(() {
                        _pageIndex = index;
                      });
                    },
                  )
                ),
                if(_pageIndex != 0)
                  Positioned(
                    top: size.height * 0.06,
                    bottom: size.width * 0.01,
                    left: size.width * 0.02,
                    right: size.width * 0.02,
                    child: GridView.builder(
                      itemCount: _pageIndex == _pageSwitchController.countAllPages ?
                      _pageSwitchController.count - _pageSwitchController.countEachPage * (_pageSwitchController.countAllPages - 1):
                      _pageSwitchController.countEachPage,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3
                      ),
                      itemBuilder: (context, index){
                        return AnalysisResultPiece(image: Image.file(File("${DataUtil.BASE_PATH}/images/poster.jpg")),pageSwitchController:_pageSwitchController, context: context,index: index, urlList: urlList,);
                      }
                    )
                  )
              ],
            ),
          )
        )
      ],
    );
  }

  void handleSearch() async{
    urlList = await net_util.recurseToGetLink(url: textEditingController.text.trim());
    /// 设置定时器
    int cou = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      Future.microtask((){
        urlList.removeWhere((element) => !element.endsWith("mp4"));
        _pageSwitchController.count = urlList.length;
        if(cou * 1 >= net_util.timeStopRecurseOfGetLink.inSeconds){
          timer.cancel();
        }
      });
    });
  }
}
/// 未能解决视频提取图片的问题，因此此时的图片是写死的，这个仅仅是九宫格的一个小格子
class AnalysisResultPiece extends StatelessWidget {
  const AnalysisResultPiece({Key? key,required this.image, required this.pageSwitchController, required this.context, required this.index, required this.urlList}) : super(key: key);
  final PageSwitchController pageSwitchController;
  final Image image;
  final BuildContext context;
  final int index;
  final List<String> urlList;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        /// 点击图片本身预览
      },
      title: image,
      subtitle: Row(
        children: [
          Expanded(
              child: TextButton(
                onPressed: () {
                  /// 预览的动作

                },
                child: const Text("预览"),
              )
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                /// 设为壁纸的动作
                /// index : [0, 8]
                /// 计算在 urlList 里面的位置 index
                /// (pageSwitchController.currentPageIndex - 1) * pageSwitchController.countEachPage + index
                DataUtil.setDynamicBgUrl(urlList[(pageSwitchController.currentPageIndex - 1) * pageSwitchController.countEachPage + index]);
              },
              child: const Text("设为壁纸"),
            )
          ),
        ],
      ),
    );
  }
}
