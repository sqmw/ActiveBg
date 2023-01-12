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
          child: Text("软件作者sq, qq请联系 1951918362, 若不能使用，请联系作者或者到github，gitee开源地址下载"),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: const [
              Expanded(
                  flex: 1,
                  child:Text("版本")
              ),
              Expanded(
                  flex: 2,
                  child:Text("1.0")
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: const [
              Expanded(
                  flex: 1,
                  child:Text("资源说明")
              ),
              Expanded(
                  flex: 2,
                  child:Text("该软件1.0版本的动态壁纸等资源均为软件测试调试以及学习使用，30天之后可能不能使用"),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: const [
              Expanded(
                  flex: 1,
                  child:Text("开源、免费")
              ),
              Expanded(
                flex: 2,
                child:Text("该软件以开源免费为原则，只要能正常启动，均不会收费"),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
          children: const [
            Expanded(
                flex: 1,
                child:Text("特点")
            ),
            Expanded(
                flex: 2,
                child:Text("动态壁纸采用了webView，可以支持html页面解析等，有着很大的拓展空间")
            )
          ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: const [
              Expanded(
                  flex: 1,
                  child:Text("展望")
              ),
              Expanded(
                  flex: 2,
                  child:Text("可能的话，将会在2.0及其以后版本加入动态壁纸对鼠标点击的支持以及为用户提供上传壁纸等功能")
              )
            ],),
        ),
        Expanded(
          flex: 1,
          child: Row(
          children: const [
            Expanded(
                flex: 1,
                child:Text("支持")
            ),
            Expanded(
                flex: 2,
                child:Text("如果您使用后对软件有不满意的地方，并且您对该类软件开发有着浓厚的兴趣且有着充足的时间，欢迎通过qq或者github等联系方式加入该软件的开发，一同完善该软件以及在android以及IOS端的开发")
            )
          ],),
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
                  child: Text("点击前往gitee："),
                ),
                Expanded(
                    flex: 2,
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
                    child:Text("点击前往github：")
                ),
                Expanded(
                    flex: 2,
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
