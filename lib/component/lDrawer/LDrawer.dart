import 'package:active_bg/component/lDrawer/children/AboutAndNotification.dart';
import 'package:active_bg/component/lDrawer/children/Settings.dart';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/utils/Win32Util.dart';
import 'package:flutter/material.dart';
import './children/TranslucentTB.dart';
import 'children/ActiveBgTransparent.dart';

class LDrawer extends StatefulWidget {
  LDrawer({Key? key}) : super(key: key);
  late Size _size;

  @override
  State<LDrawer> createState() => _LDrawerState();
}

class _LDrawerState extends State<LDrawer> {


  @override
  Widget build(BuildContext context) {
    widget._size = MediaQuery.of(context).size;
    return Container(
      color: Colors.grey,
      width: widget._size.width * 0.2,
      height: widget._size.height,
      child: Column(
        children: [
          // 开启桌面任务栏透明
          const Expanded(
            flex: 1,
            child: SizedBox(
              child: TranslucentTB(),
            )
          ),
          Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {
                  Win32Util.destroyActiveBgWin();
                },
                child: const Text("关闭动态壁纸"),
              )
          ),
          const Expanded(
              flex: 1,
              child: ActiveBgTransparent()
          ),
          Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {

                },
                child: const Text("本地视频/图片"),
              )
          ),
          Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {

                },
                child: const Text("捐助"),
              )
          ),
         const Expanded(
            flex: 1,
            child: AboutAndNotification()
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
