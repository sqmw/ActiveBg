import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAndNotification extends StatefulWidget {
  const AboutAndNotification({Key? key}) : super(key: key);

  @override
  State<AboutAndNotification> createState() => _AboutAndNotificationState();
}

class _AboutAndNotificationState extends State<AboutAndNotification> {
  late Size _size;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return  TextButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title: const Text("关于/通知"),
                content:  Column(
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
                              child:Text("2.0")
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
                            child:Text("该软件2.0版本的动态壁纸等资源均为软件测试调试以及学习使用，30天之后可能不能使用"),
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
                              child:Text("动态壁纸采用了webView，可以支持html页面解析等，有较大的拓展空间")
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
                              child:Text("可能的话，将会在3.0及其以后版本加入动态壁纸对鼠标点击的支持以及为用户提供上传壁纸等功能")
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
                              child:Text("如果您使用后对软件有不满意的地方，并且您对该类软件开发有着浓厚的兴趣且有着充足的时间，欢迎通过qq或者github等联系方式加入该软件的开发，一同完善该软件的开发")
                          )
                        ],),
                    ),
                    const Divider(),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          const Expanded(
                              flex: 1,
                              child:Text("new features", style: TextStyle(color: Colors.deepPurple),)
                          ),
                          Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 60,
                                width: _size.width,
                                child:  ListView(
                                  children: const [
                                    Text("1. 支持对链接的解析", style: TextStyle(color: Colors.deepPurple),),
                                    Text("2. 支持对喜欢的壁纸的下载", style: TextStyle(color: Colors.deepPurple),),
                                    Text("3. 支持手动关闭动态壁纸", style: TextStyle(color: Colors.deepPurple)),
                                    Text("4. 支持设置窗口透明度", style: TextStyle(color: Colors.deepPurple)),
                                    Text("5. 可以查看/设置本地的动态壁纸", style: TextStyle(color: Colors.deepPurple)),
                                  ],
                                ),
                              )
                          )
                        ],),
                    ),
                    const Divider(),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          const Expanded(
                              flex: 1,
                              child:Text("bugs fixed", style: TextStyle(color: Colors.red),)
                          ),
                          Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 60,
                                width: _size.width,
                                child:  ListView(
                                  children: const [
                                    Text("1. 兼容问题", style: TextStyle(color: Colors.red),),
                                    Text("2. 无网络报错修复", style: TextStyle(color: Colors.red)),
                                    Text("3. 首次设置黑屏问题", style: TextStyle(color: Colors.red)),
                                    Text("4. 静态壁纸搜索返回链接错误", style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              )
                          )
                        ],),
                    ),
                    const Divider(),
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
                ),
              );
            }
        );
      },
      child: const Text("关于/通知"),
    );
  }
}
