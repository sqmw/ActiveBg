import 'package:flutter/material.dart';

import 'package:active_bg/utils/NetUtil.dart' as net_util show Data, ResponseActions, CommunicationTaskQueueLoop;
import 'package:active_bg/utils/JavaScriptUtil.dart' as javascript_util;
import 'package:active_bg/utils/ConfigUtil.dart' as config_util show volume, saveConfig;

/// 用来调节音量的
class ActiveBgVolume extends StatefulWidget {
  const ActiveBgVolume({Key? key}) : super(key: key);

  @override
  State<ActiveBgVolume> createState() => _ActiveBgVolumeState();
}

class _ActiveBgVolumeState extends State<ActiveBgVolume> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: Icon(Icons.volume_up, color: Colors.deepPurple,)
        ),
        Expanded(
          flex: 2,
          child: Slider(
            value: config_util.volume,
            min: 0,
            max: 1,
            onChanged: (val){
              setState(() {
                config_util.volume = val;
                net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: "script.js", doBefore: (){
                  net_util.Data.scriptFileRelativePath = "/script.js";
                  javascript_util.rewriteJavaScript(javascript_util.setVolumeOfVideo(val));
                });
                config_util.saveConfig();
              }
              );
            }
          )
        )
      ],
    );
  }
}
