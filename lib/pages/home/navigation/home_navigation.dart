import 'package:flutter/material.dart';
import 'nav_items.dart';

class HomeNavigation extends StatelessWidget {
  final TabController tabController;
  
  const HomeNavigation({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicator: const BoxDecoration(
        color: Colors.deepPurple,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      controller: tabController,
      tabs: navItems.map((item) => Tab(text: item.label)).toList(),
    );
  }
}
