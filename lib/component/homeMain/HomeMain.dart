import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:active_bg/component/homeMain/children/DynamicBg.dart';
import 'package:active_bg/component/homeMain/children/StaticSearch.dart';
import 'package:active_bg/component/homeMain/children/StaticRecommend.dart';
import 'package:active_bg/component/homeMain/children/TimeChange.dart';
import 'package:active_bg/component/lDrawer/LDrawer.dart';
import 'package:active_bg/utils/Win32Util.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

import '../lDrawer/children/Settings.dart';
import './children/FullOrFullExitButton.dart';
import 'children/linkAnalysis/LinkAnalysis.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({Key? key}) : super(key: key);
  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> with TickerProviderStateMixin {
  late final TabController _tabController;
  /// 申明的是引用
  late POINT cursorPosBefore;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this,initialIndex: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LDrawer(),
      appBar: AppBar(
        /// 没有添加 GestureDetector
        title: TabBar(
          // labelStyle: TextStyle(fontFamily: "黑体"),
          /// 这个属性设置之后会变成一堆
          // isScrollable: true,
          /// 这个表示的是点击之后的标识，默认是一条横线
          indicator: const BoxDecoration(
            color: Colors.deepPurple,
          ),
          // indicatorWeight: 3,
          indicatorColor: Colors.deepPurple,
          controller: _tabController,
          tabs: const [
            Text(
              "静态壁纸",
            ),
            Text(
              "搜索静态壁纸",
            ),
            Text(
              "定时切换",
            ),
            Text(
              "动态壁纸",
            ),
            Text(
              "链接解析",
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return const Setting();
              }));
            },
            icon: const Icon(Icons.settings)
          ),
          const VerticalDivider(
            thickness: 2,
          ),
          IconButton(
            onPressed: (){
              ShowWindow(Win32Util.hWndActiveBg, SW_MINIMIZE);
            },
            icon: const Icon(Icons.minimize)
          ),
          /// 经过测试，这个点击两次之后就会失效
          const FullOrFullExitButton(),
          IconButton(
            onPressed: (){
              exit(-1);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      /// _homeMainPartList[_currentIndex]
      body: TabBarView(
        controller: _tabController,
        children: const [
        StaticRecommend(),
        StaticSearch(),
        TimeChange(),
        DynamicBg(),
        LinkAnalysis(),
      ],),
    );
  }
}
