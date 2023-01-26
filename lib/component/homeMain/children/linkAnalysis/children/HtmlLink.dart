import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:active_bg/component/homeMain/children/linkAnalysis/children/PageSwitchBar.dart';
import 'package:active_bg/component/homeMain/children/linkAnalysis/children/PageSwitchController.dart';
import 'package:active_bg/mixins/UriAnalysis.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'package:active_bg/utils/Win32Util.dart';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/interfaces/Preview.dart';
import 'package:active_bg/component/viewUtils/ImageView.dart';
import 'package:active_bg/utils/NetUtil.dart' as net_util show recurseToGetLink, Data, ResponseActions;
/**
 * 对应链接解析
 */

/// 关于链接递归搜索的实现
/// 实现方法：isolate进程递归，通过 ReceivePort 实现了每当递归搜索数量达到一定数量之后就通过SendPort发送出新的urlList
/// 每当send message的时候就会更新，然后根据发出的 urlList 更新 urlList
///
/// 如何提取视频的一帧图片，通过和浏览器交互，借助浏览器提取出视频的一帧图片，之后通过httpServer传输给backend
/// 实现是：每当点击下一页的时候，就先判断是否已经有了base64的图片，否则就会和浏览器交互
class HtmlLink extends StatefulWidget {
  const HtmlLink({Key? key}) : super(key: key);

  @override
  State<HtmlLink> createState() => _HtmlLinkState();
}

class _HtmlLinkState extends State<HtmlLink> with UriAnalysis{
  late PageSwitchController _pageSwitchController;
  int _pageIndex = 0;
  /// 这个引用对应的地址会经常变化，因为使用了 receivePort
  late List<String> _urlList;
  /// 在点击搜索的时候进行初始化，存储返回的结果
  late Map<String, String> _imgBase64Map;
  /// 用来发送给 fronted
  late Map<String, String> _imgUrlMap;
  String _searchKey = "";
  int _currentPageItemCount = -1;
  /// 表示的是该页的item的最开始的item的index
  int _itemIndexLeading = 0;
  /// 用来保存当前的每一个 item 的 widget 的key，方便刷新
  final List<GlobalKey> _itemOfAnalysisResultKeyList = List.filled(9, GlobalKey(), growable: false);

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

                      /// 将页总数设置为 0
                      _pageSwitchController.currentPageIndex = 0;
                      _pageIndex = 0;

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
          child: Stack(
            children: [
              Positioned(
                right: size.width * 0.02,
                top: 0,
                child: PageSwitchBar(
                  pageSwitchController: _pageSwitchController,
                  /// 表示的是鼠标点击我们定义的事件的时候需要做的事情，这个函数有组件定义，但是组件的函数暴露在了父组件里面，可以实现通信
                  onPageIndexChange: (int index) {
                    /// 每次切换页面需要重新读写当前的页面的itemCount
                    _currentPageItemCount = _pageIndex == _pageSwitchController.countAllPages ?
                    _pageSwitchController.count - _pageSwitchController.countEachPage * (_pageSwitchController.countAllPages - 1):
                    _pageSwitchController.countEachPage;
                    _itemIndexLeading = (_pageSwitchController.currentPageIndex - 1) * _pageSwitchController.countEachPage;
                    /// 需要判定是否已经存储，一般判断是否为null即可
                    if(_imgBase64Map["$_itemIndexLeading"] == null || _imgBase64Map["$_itemIndexLeading"]!.isEmpty){
                      _imgUrlMap = {};
                      // print("currentPageItemCount -> ${_currentPageItemCount}");
                      for (int i = 0; i < _currentPageItemCount; i++) {
                        /// (pageSwitchController.currentPageIndex - 1) * pageSwitchController.countEachPage + index
                        /// 这里的位置错误还没有解决
                        try{
                          _imgUrlMap["${_itemIndexLeading + i}"] =
                          _urlList[_itemIndexLeading + i];
                        }catch (e){
                          break;
                        }
                        // print("urlList->${_urlList.length}, nowIndex -> ${_itemIndexLeading + i}");
                      }
                      // log("${_imgUrlMap.length}"); // 可以接收到
                      /// 可以看书，当我们的切面切换开之后，只要是浏览过的页面，任然是处于加载状态
                      net_util.Data.setCommunicationMsg(action: net_util.ResponseActions.getImgFromVideo, data: _imgUrlMap);
                      net_util.Data.base64ReceivePort = ReceivePort();
                      /// {index(*String*): base64}
                      int cou = 0;
                      net_util.Data.base64ReceivePort.listen((data) {
                        /// 将图片的信息存储在内存里面，方便显示
                        cou ++;
                        _imgBase64Map[data["index"]] = data["base64"];
                        /// 这样会导致屏幕闪烁
                        // setState(() {});
                        /// 这里可能存在之前的线程
                        if(index == _pageSwitchController.currentPageIndex){
                          _itemOfAnalysisResultKeyList[int.parse(data["index"]) - (_pageSwitchController.currentPageIndex - 1) * _pageSwitchController.countEachPage].currentState!.setState(() { });
                        }
                        if(cou >= _currentPageItemCount){
                          net_util.Data.base64ReceivePort.close();
                        }
                        /// 刷新对应的图片，切换掉原来的死图片
                      });
                    }
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
                    /// 当前页面的 itemCount
                    itemCount: _currentPageItemCount,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: Win32Util.whRate,
                    ),
                    itemBuilder: (context, index){
                      /// 重新赋值
                      _itemOfAnalysisResultKeyList[index] = GlobalKey();
                      return ItemOfAnalysisResult(
                        key: _itemOfAnalysisResultKeyList[index],
                        /// 这里是一个三目运算符
                        imgBase64Map: _imgBase64Map,
                        pageSwitchController:_pageSwitchController,
                        context: context,
                        index: index,
                        urlList: _urlList,);
                    }
                  )
                )
            ],
          )
        )
      ],
    );
  }

  void handleSearch() async{
    _imgBase64Map = {};
    /// 这个是我们返回的引用，其实就是指针
    ReceivePort receivePort = ReceivePort();
    net_util.Data.recurseGetLinkListReceivePort?.close();
    net_util.Data.recurseGetLinkListReceivePort = receivePort;
    net_util.recurseToGetLink(url: textEditingController.text.trim(), sendPort: receivePort.sendPort);
    receivePort.listen((message) {
      if(message["canClose"]){
        receivePort.close();
      }else{
        _urlList = message["list"];
        /// 剔除没有含有 mp4 的
        _urlList.removeWhere((element) => !element.endsWith("mp4"));
        _pageSwitchController.count = _urlList.length;
      }
    });
  }
}
/// 未能解决视频提取图片的问题，因此此时的图片是写死的，这个仅仅是九宫格的一个小格子
/// 通过和浏览器交互，实现了图片的提取
/// 上面的一个是 stateless 的，避免了刷新时候闪烁的问题
/// 这个是 stateful 的
class ItemOfAnalysisResult extends StatefulWidget{
  const ItemOfAnalysisResult({Key? key,required this.imgBase64Map, required this.pageSwitchController, required this.context, required this.index, required this.urlList}) : super(key: key);
  final PageSwitchController pageSwitchController;
  final Map<String, String> imgBase64Map;
  final BuildContext context;
  final int index;
  final List<String> urlList;

  @override
  State<StatefulWidget> createState() => ItemOfAnalysisResultState();
}

class ItemOfAnalysisResultState extends State<ItemOfAnalysisResult>implements Preview{
  /// 表示的是 urlList 或者是 baseList 里面的长度
  late final int _indexOfAll;

  @override
  void initState() {
    super.initState();
    /// index : [0, 8]
    /// 计算在 urlList 里面的位置 index
    /// (pageSwitchController.currentPageIndex - 1) * pageSwitchController.countEachPage + index
    _indexOfAll = (widget.pageSwitchController.currentPageIndex - 1) * widget.pageSwitchController.countEachPage + widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        preview();
        /// 点击图片本身预览
      },
      /// 这个就是显示的图片
      title: AnimatedOpacity(
        opacity: widget.imgBase64Map["$_indexOfAll"] == null || widget.imgBase64Map["$_indexOfAll"]!.isEmpty?0.5:1,
        duration: const Duration(milliseconds: 500),
        child: widget.imgBase64Map["$_indexOfAll"] == null || widget.imgBase64Map["$_indexOfAll"]!.isEmpty?Image.file(File("${DataUtil.BASE_PATH}/images/poster.jpg")):Image.memory(base64.decode(widget.imgBase64Map["$_indexOfAll"]!)),
      ),
      subtitle: Row(
        children: [
          Expanded(
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState){
                    return TextButton(
                      onPressed: () {
                        /// 预览的动作
                        preview();
                      },
                      child:const Text("桌面预览"),
                    );
                  })
          ),
          Expanded(
              child: TextButton(
                onPressed: () {
                  /// 设为壁纸的动作
                  DataUtil.setDynamicBgUrl(widget.urlList[_indexOfAll]);
                },
                child: const Text("设为壁纸"),
              )
          ),
        ],
      ),
    );
  }

  @override
  void preview({data}) {
    // TODO: implement preview
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context){
          return ImageView(
            image: widget.imgBase64Map["$_indexOfAll"] == null || widget.imgBase64Map["$_indexOfAll"]!.isEmpty?
            Image.file(fit: BoxFit.fill,File("${DataUtil.BASE_PATH}/images/poster.jpg")):
            Image.memory(fit: BoxFit.fill, base64.decode(widget.imgBase64Map["$_indexOfAll"]!)),
          );
        }
    );
  }
}