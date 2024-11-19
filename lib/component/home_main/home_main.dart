import 'package:active_bg/component/home_main/children/dynamic_bg.dart';
import 'package:active_bg/pages/palette_navigate.dart';
import 'package:active_bg/component/home_main/children/static_rearch.dart';
import 'package:active_bg/component/home_main/children/static_recommend.dart';
import 'package:active_bg/component/home_main/children/time_change.dart';
import 'package:active_bg/component/l_drawer/l_drawer.dart';
import 'package:flutter/material.dart';

import 'children/settings.dart';
import 'children/linkAnalysis/link_analysis.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({Key? key}) : super(key: key);
  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> with TickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this,initialIndex: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LDrawer(),
      drawerEdgeDragWidth: 400,
      appBar: AppBar(
        elevation: 0,
        title: TabBar(
          indicator: const BoxDecoration(
            color: Colors.deepPurple,
            // borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
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
                return const PaletteNavigate();
              }));
            },
            icon: const Icon(Icons.palette)
          ),
          IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return const Setting();
              }));
            },
            icon: const Icon(Icons.settings)
          ),
        ],
      ),
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
