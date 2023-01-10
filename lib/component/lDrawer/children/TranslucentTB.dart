import 'package:active_bg/utils/TranslucentTBUtil.dart';
import 'package:flutter/material.dart';
class TranslucentTB extends StatefulWidget {
  const TranslucentTB({Key? key}) : super(key: key);

  @override
  State<TranslucentTB> createState() => _TranslucentTBState();
}
// 目前该部分借助软件TranslucentTB来完成，后期有时间可以自己在这里完成
class _TranslucentTBState extends State<TranslucentTB> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
        if(!TranslucentTBUtil.isTranslucentTBRun()){
          TranslucentTBUtil.runTranslucentTB();
        }
        showDialog(
          context: context,
          builder: (context){
            return const AlertDialog(
              title: Text("提示"),
              content: Text("TaskBar透明程序已经运行，右键点击TranslucentTB可进行设置"),
            );
        });
      },
      child:const  Text("开启TaskBar透明") );
  }
}
