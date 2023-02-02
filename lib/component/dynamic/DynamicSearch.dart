import 'dart:async';

import 'package:active_bg/utils/Win32Util.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html_dom;

import 'package:active_bg/interfaces/Preview.dart';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/component/viewUtils/ImageView.dart';
import 'package:active_bg/utils/NetUtil.dart' as net_util show dynamicBgVideoDownload;

/// 这个表示点击任何一个页面进入之后的结果以及搜索的结果（实际上都是搜索结果）
/// 搜索的时候因为结果可能是动态的可能是静态的，所以展示的时候，只展示一种结果
class DynamicSearchSet extends StatefulWidget {
  const DynamicSearchSet(this._searchUrl,{Key? key}) : super(key: key);
  final String _searchUrl;

  @override
  State<DynamicSearchSet> createState() => _DynamicSearchSetState();
}

class _DynamicSearchSetState extends State<DynamicSearchSet> implements Preview{
  int _currentPage = 1;
  late final ScrollController _scrollController;
  /// 每次build都会加载新的
  bool _canBuild = true;
  bool _resultEnd = false;
  String _getSearchContextByPage(){
    _currentPage++;
    if(_currentPage-1 == 1){
      if(widget._searchUrl.contains("search")){
        return "page=1";
      }
      return "";
    }else{
      if(widget._searchUrl.contains("dtag_109")){
        return "index_$_currentPage.shtml";
      }else if(widget._searchUrl.contains("search")){
        return "page=$_currentPage";
      }
      return "p${++_currentPage}";
    }
  }
  final List<Widget> _searchResultList = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    /// scrollController添加监听器
    /// 作防抖，每次
    bool canLoad = true;
    _scrollController.addListener(() {
      if(_scrollController.offset == _scrollController.position.maxScrollExtent){
        if(canLoad){
          _canBuild = true;
          setState(() {});
          canLoad = !canLoad;
          Timer(const Duration(seconds: 2),(){
            canLoad = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("结果"),
      ),
      body: _getBody()
    );
  }

  // region
  void loadResearchInfo(dynamic data) {
    List<html_dom.Element> eleList = DataUtil.getEleListFromStrBySelector("$data", DataUtil.QUERY_VIDEO_PAGE_LIST);
    if(eleList.isEmpty){
      /// 表示没有更多的了
      _resultEnd = true;
      _searchResultList.add(const Center(child: Image(image: NetworkImage("https://img1.doubanio.com/view/photo/l/public/p2527054668.webp")),));
    }
    for(html_dom.Element element in eleList){
      _searchResultList.add(ListTile(
        onTap: (){
          preview(data: "${element.children[0].attributes["src"]}");
        },
        title: Image(
          /// 这里使用静态的，防止太大的内存开销
          image: NetworkImage("${element.children[0].attributes["src"]}"),
        ),
        subtitle: Row(
          children: [
            Expanded(
                child: TextButton(
                  onPressed: () {
                    DataUtil.dio.get("${element.attributes["href"]}")
                        .then((res){
                      html_dom.Element videoEle = DataUtil.getEleListFromStrBySelector("${res.data}", DataUtil.QUERY_VIDEO)[0];
                      net_util.dynamicBgVideoDownload(videoUrl:videoEle.attributes["src"]!, imgUrl: "${element.children[0].attributes["src"]}");
                    });
                  },
                  child: const Text("下载"),
                )
            ),
            Expanded(
                child: TextButton(
                  onPressed: () {
                    DataUtil.dio.get("${element.attributes["href"]}")
                        .then((res){
                      html_dom.Element videoEle = DataUtil.getEleListFromStrBySelector("${res.data}", DataUtil.QUERY_VIDEO)[0];
                      DataUtil.setDynamicBgUrl(videoEle.attributes["src"]!);
                    })
                        .catchError((err){

                    });
                  },
                  child: const Text("设为壁纸"),
                )
            ),
          ],
        ),
      ));
    }
  }
  // endregion

  @override
  void preview({data}) {
    // TODO: implement preview
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context){
          return ImageView(
            image: Image(
              fit: BoxFit.fill,
              image: NetworkImage(data),
            ),
          );
        }
    );
  }

  Widget _getBody() {
    /// 每次更新之后需要重新build
    if(_canBuild && !_resultEnd){
      _canBuild = false;
      return FutureBuilder(
        future: DataUtil.dio.get(widget._searchUrl + _getSearchContextByPage()),
        builder: (
          BuildContext context,
          AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
              /// 加载 _searchResultList
              //log("url: " + widget._searchUrl + _getSearchContextByPage());
              loadResearchInfo(snapshot.data);
              return GridView.count(
                controller: _scrollController,
                childAspectRatio: Win32Util.whRate,
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                children: _searchResultList,
              );
            }else{
              return Center(
                child: Text("${snapshot.error}"),
              );
            }
          }else{
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    }else{
      return GridView.count(
        controller: _scrollController,
        childAspectRatio: Win32Util.whRate,
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        children: _searchResultList,
      );
    }
  }
}
