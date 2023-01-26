import 'package:flutter/cupertino.dart';

/// 用来控制页面切换

class PageSwitchController  {
  /// 每一页的数量
  int _countEachPage = 9;
  /// 当前的页码，0 表示什么都没有 1 表示的是第一页
  int _currentPageIndex = 0;
  /// 总共的展示的数量
  int _count = 0;
  /// page的数量
  int _countAllPages = 0;

  int get currentPageIndex =>  _currentPageIndex;
  set currentPageIndex(int newIndex){
    _currentPageIndex = newIndex;
  }

  late final State _stateOwner;


  set stateOwner(State value) {
    _stateOwner = value;
  }

  /// 表示的是 item 的数量
  int get count =>  _count;
  set count(int newCount){
    _count = newCount;
    _countAllPages = (_count / _countEachPage).ceil();
    _stateOwner.setState((){});
  }

  /// 表示的是 page 的数量
  int get countAllPages => _countAllPages;


  int get countEachPage => _countEachPage;

  set countEachPage(int value) {
    _countEachPage = value;
    _countAllPages = (_count / _countEachPage).ceil();
  }

  PageSwitchController({int countEachPage = 9});
}