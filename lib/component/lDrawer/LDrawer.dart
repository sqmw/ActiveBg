import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {

                },
                child: Text("捐助"),
              )
          ),
          Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {

                },
                child: Text("关于"),
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
