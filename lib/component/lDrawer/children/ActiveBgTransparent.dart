import 'dart:isolate';

import 'package:active_bg/utils/Win32Util.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:active_bg/utils/ConfigUtil.dart' as config;
import '../../../utils/DataUtil.dart';

class ActiveBgTransparent extends StatefulWidget {
  const ActiveBgTransparent({Key? key}) : super(key: key);

  @override
  State<ActiveBgTransparent> createState() => _ActiveBgTransparentState();
}

class _ActiveBgTransparentState extends State<ActiveBgTransparent> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: Text("透明度",textAlign: TextAlign.center,style: TextStyle(color: Colors.deepPurple),)
        ),
        Expanded(
          flex: 2,
          child: Slider(
            label: DataUtil.opacity.toString(),
            value: DataUtil.opacity,
            min: 50,
            max: 255,
            onChanged: (val){
              setState(() {
                DataUtil.opacity = val;
                Win32Util.setActiveBgTransparent(DataUtil.opacity.toInt());
                Future.microtask((){
                  config.saveConfig();
                });
              });
          }
        ))
      ],
    );
  }
}
