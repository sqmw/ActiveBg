import 'package:active_bg/component/homeMain/children/DynamicBg.dart';
import 'package:active_bg/component/homeMain/children/Personal.dart';
import 'package:active_bg/component/homeMain/children/Recommend.dart';
import 'package:active_bg/component/homeMain/children/SelfDefine.dart';
import 'package:active_bg/component/lDrawer/LDrawer.dart';
import 'package:flutter/material.dart';
import '../../utils/DataUtil.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({Key? key}) : super(key: key);
  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final List<Widget> _homeMainPartList = const [
    Recommend(),
    Personal(),
    SelfDefine(),
    DynamicBg(),
  ];

  int _currentIndex = 3;

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
                },
                child: const Text(
                  "推荐",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: ()async{
                  if(_currentIndex != 1){
                    setState(() {
                      _currentIndex = 1;
                    });
                  }
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
                },
                child: const Text(
                  "自定义",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: (){
                  if(_currentIndex != 3){
                    setState(() {
                      _currentIndex = 3;
                    });
                  }
                },
                child: const Text(
                  "动态壁纸",
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
