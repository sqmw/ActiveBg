import 'package:active_bg/component/homeMain/children/Palette.dart';
import 'package:flutter/material.dart';

/// 这个类是用来进行 Palette 导航的，其所有的dart文件中仅仅该文件的child涉及js
class PaletteNavigate extends StatefulWidget {
  const PaletteNavigate({Key? key}) : super(key: key);

  @override
  State<PaletteNavigate> createState() => _PaletteNavigateState();
}

class _PaletteNavigateState extends State<PaletteNavigate> with TickerProviderStateMixin{
  late final TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          indicator: const BoxDecoration(
            color: Colors.deepPurple,
          ),
          // indicatorWeight: 3,
          indicatorColor: Colors.deepPurple,
          controller: _tabController,
          tabs: const [
            Text("Palette")
          ],
        ),
      ),
      /// Navigator会监听路由
      body: Navigator(
        initialRoute: "/palette",
        onGenerateRoute: (RouteSettings settings){
          switch(settings.name){
            case "/palette":{
              return MaterialPageRoute(builder: (BuildContext context) {
                return const Palette();
              });
            }
          }
        },
      ),
    );
  }
}
