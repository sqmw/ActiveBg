import 'package:active_bg/component/lDrawer/children/About.dart';
import 'package:flutter/material.dart';
import './children/TranslucentTB.dart';

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
          Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {

                },
                child:const TranslucentTB(),
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
          Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context){
                      return const AlertDialog(
                        title: Text("介绍"),
                        content:  About(),
                      );
                    }
                  );
                },
                child: const Text("关于"),
              )
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
