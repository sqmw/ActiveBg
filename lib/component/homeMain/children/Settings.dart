import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
      ),
      body: Column(
        children: const [
          Text("主题/字体"),
          Text("问题反馈")
        ],
      ),
    );
  }
}
