import 'package:active_bg/component/homeMain/children/Personal.dart';
import 'package:active_bg/component/homeMain/children/Recommend.dart';
import 'package:active_bg/component/homeMain/children/SelfDefine.dart';
import 'package:active_bg/component/lDrawer/LDrawer.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class HomeMain extends StatefulWidget {
  const HomeMain({Key? key}) : super(key: key);
  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final List<Widget> _homeMainPartList = const [
    Recommend(),
    Personal(),
    SelfDefine()
  ];

  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: (){
                  if(_currentIndex != 0){
                    setState(() {
                      _currentIndex = 0;
                    });
                  }
                  developer.log("推荐");
                },
                child: const Text(
                  "推荐",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: (){
                  if(_currentIndex != 1){
                    setState(() {
                      _currentIndex = 1;
                    });
                  }
                  developer.log("个性化");
                },
                child: const Text(
                  "个性化",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: (){
                  if(_currentIndex != 2){
                    setState(() {
                      _currentIndex = 2;
                    });
                  }
                  developer.log("自定义");
                },
                child: const Text(
                  "自定义",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _homeMainPartList[_currentIndex],
    );
  }
}
