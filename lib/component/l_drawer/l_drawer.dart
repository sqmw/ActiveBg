import 'package:active_bg/component/l_drawer/children/about_and_notification.dart';
import 'package:flutter/material.dart';
import 'children/translucent_tb.dart';
import 'children/active_bg_transparent.dart';
import 'children/active_bg_volume.dart';

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
          const Expanded(
            flex: 1,
            child: ActiveBgVolume(),
          ),
          Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {
                  // Win32Util.destroyActiveBgWin();
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
