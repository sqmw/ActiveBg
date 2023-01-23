import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

import '../../../utils/DataUtil.dart';
import '../../viewUtils/NetCheck.dart';

class StaticSearch extends StatefulWidget {
  const StaticSearch({Key? key}) : super(key: key);

  @override
  State<StaticSearch> createState() => _StaticSearchState();
}

class _StaticSearchState extends State<StaticSearch> {
  late TextEditingController _keyController;
  late final String _searchResource = "设置资源";
  late Size _size;
  late final ScrollController _scrollController;
  List<ListTile> _listTileList= [];
  List<String> _imgUrlList = [];
  /// 用于防抖
  bool _canLoad = true;
  Timer? _canLoadTimer;

  void _search() {
    if(_keyController.text.isNotEmpty){
      _listTileList = [];
      loadImgListTile();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _keyController = TextEditingController();
    _keyController.addListener(() {
    });

    _scrollController.addListener(() {
      if(_scrollController.offset / _scrollController.position.maxScrollExtent == 1){
        if(_canLoad){
          loadImgListTile();
          _canLoad = !_canLoad;
        }else{
          _canLoadTimer?.cancel();
          _canLoadTimer = Timer(const Duration(seconds: 1),(){
            _canLoad = !_canLoad;
          });
        }
      }
    });
  }

  void loadImgListTile(){
    ()async{
      _imgUrlList = await DataUtil.getImgAbsUrls(ques: _keyController.text, start: DataUtil.getRandomInt());
      for (var value in _imgUrlList){
        _listTileList.add(await DataUtil.getImageListTile(context,value));
        log("${_listTileList.length}");
      }
      setState((){});
    }();
  }

  @override
  Widget build(BuildContext context) {
    log("build refresh listTileCount -> ${_listTileList.length} -> begin get net img urls");
    _size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context){
                        return const Text("选择资源");
                    });
                  },
                  child: Text(_searchResource),)
              ),
              Expanded(
                flex: 4,
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (RawKeyEvent keyEvent){
                    if(keyEvent.runtimeType == RawKeyDownEvent){
                      /// 表示在windows操作系统下面
                      if(keyEvent.data is RawKeyEventDataWindows){
                        /// 判定是否为enter键
                        if(keyEvent.logicalKey.keyId == LogicalKeyboardKey.enter.keyId){
                          _search();
                        }
                      }
                    }
                  },
                  child: TextField(
                  controller: _keyController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "请输入搜索关键字",
                    suffix: IconButton(
                      onPressed: () {
                        _search();
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ),)
              )
            ],
          )
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: _size.height * 0.12,
          child: NetCheck(
            child: SizedBox(
              child: GridView.count(
                controller: _scrollController,
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: _listTileList,
              ),
            ),
          ),
        ),
      ],
    );
  }
}