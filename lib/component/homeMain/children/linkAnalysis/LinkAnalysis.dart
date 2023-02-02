import 'package:active_bg/component/homeMain/children/linkAnalysis/children/AnalysisTypeSelector.dart';
import 'package:active_bg/component/homeMain/children/linkAnalysis/children/HtmlLink.dart';
import 'package:active_bg/component/homeMain/children/linkAnalysis/children/LocalFileOrNetVideo.dart';
import 'package:flutter/material.dart';

/// 可以支持各种链接的解析、包含本地的文件路径，或者是网页的链接等

final Map<String, dynamic> data = {
  "options": {
    "本地文件地址/mp4链接": 0,
    "网页链接": 1
  },
  "index": 0,
};

const List<Widget> widgetList = [
  LocalFileOrNetVideo(),
  HtmlLink()
];

class LinkAnalysis extends StatefulWidget {
  const LinkAnalysis({Key? key}) : super(key: key);

  @override
  State<LinkAnalysis> createState() => _LinkAnalysisState();
}

class _LinkAnalysisState extends State<LinkAnalysis> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                 Expanded(
                  flex: 2,
                  /// 自定义的下拉框
                  child: AnalysisTypeSelector(
                    data: data,
                    onChangeFatherDo: (){
                      setState((){});
                    },
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    color: Colors.white,
                  ),
                )
              ],
            )
          ),
          Expanded(
            flex: 10,
            child: widgetList[data["index"]],
          )
        ],
      ),
    );
  }
}