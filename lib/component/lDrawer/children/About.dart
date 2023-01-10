import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: Text("软件/程序作者sq, qq请联系 1951918362, 若不能使用，请联系作者或者到github，gitee开源地址下载"),
        ),
        Expanded(
          flex: 1,
          child: TextButton(
            onPressed: (){
              launchUrl(Uri.parse("https://gitee.com/s99q/ActiveBg"));
            },
            child:  Row(
              children:const [
                Expanded(
                  flex: 1,
                  child: Text("点击前往gitee地址："),
                ),
                Expanded(
                    flex: 1,
                    child: Text("https://gitee.com/s99q/ActiveBg")
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: TextButton(
            onPressed: (){
              launchUrl(Uri.parse("https://github.com/sqmw/ActiveBg"));
            },
            child: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child:Text("点击前往github地址：")
                ),
                Expanded(
                  flex: 1,
                  child:Text("https://github.com/sqmw/ActiveBg")
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
