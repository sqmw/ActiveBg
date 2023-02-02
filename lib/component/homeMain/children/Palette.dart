import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:active_bg/utils/Win32Util.dart';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:active_bg/interfaces/Preview.dart';
import 'package:active_bg/component/viewUtils/ImageView.dart';
import 'package:active_bg/utils/NetUtil.dart' as net_util show Data, ResponseActions, ActiveDynamicBgSpecialImgInfo, ActiveDynamicBgVideoInfo, CommunicationTaskQueueLoop, SpecialSubjoin, MouseAction;
import 'package:active_bg/utils/JavaScriptUtil.dart' as javascript_util;
import 'package:active_bg/utils/ConfigUtil.dart' as config_util show BgType;

class Palette extends StatefulWidget {
  const Palette({Key? key}) : super(key: key);

  @override
  State<Palette> createState() => _PaletteState();
}

class _PaletteState extends State<Palette> implements Preview{
  /// 将script文件夹下面的所有script读来放在这里
  late final List<javascript_util.ScriptInfo> scriptList;
  final List<ListTile> _paletteItemList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      /// 这个函数是一个 future
      future:  javascript_util.getLocalScriptInfo(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasData){
            scriptList = snapshot.data;
            for (javascript_util.ScriptInfo element in scriptList) {
              _paletteItemList.add(createPaletteItem(showName: element.showName,fileRelativePath: element.fileRelativePath, scriptName: element.fileName, isImg: element.isImg));
            }
            return GridView.count(
              childAspectRatio: Win32Util.whRate,
              crossAxisCount: 3,
              children: _paletteItemList,
            );
          }else{
            return Text("${snapshot.error}");
          }
        }else{
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    });
  }

  @override
  void preview({data}) {
    // TODO: implement preview
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context){
          return ImageView(image: Image.file(fit: BoxFit.fill,File("${DataUtil.BASE_PATH}/images/poster.jpg")));
        }
    );
  }

  ListTile createPaletteItem({required String showName,required String fileRelativePath,required String scriptName, required bool isImg}){
    return ListTile(
        onTap: (){
          preview();
        },
        title: Image.file(fit: BoxFit.fill,File("${DataUtil.BASE_PATH}/images/poster.jpg")),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(showName, textAlign: TextAlign.center)
            ),
            Expanded(
              /// 取消按钮
                child: TextButton(
                  onPressed: (){
                    /// 取消鼠标 msg
                    //  net_util.MouseAction.stopMouseAction();
                    /// 刷新
                    net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: "script.js", doBefore: (){
                      net_util.Data.scriptFileRelativePath = "/script.js";
                      javascript_util.rewriteJavaScript(javascript_util.reloadHtml);
                    });
                    /// 过200毫秒再将任务丢进任务队列
                    Timer(const Duration(milliseconds: 200),(){
                      /// 表示的是取消设定的subJoin，并且设置原有 video以及 special_img的处理
                      if(!isImg){
                        if(net_util.ActiveDynamicBgVideoInfo.urlOrPath.isNotEmpty){
                          Timer(const Duration(milliseconds: 100), () {
                            if(config_util.BgType.type == config_util.BgType.specialImg){
                              /// 移除 video
                              net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: "script.js", doBefore: (){
                                net_util.Data.scriptFileRelativePath = "/script.js";
                                javascript_util.rewriteJavaScript(javascript_util.removeElement(javascript_util.videoId));
                              });
                            }else{
                              DataUtil.setDynamicBgUrl(net_util.ActiveDynamicBgVideoInfo.urlOrPath);
                            }
                          });
                        }
                      /// 表示需要取消 special_img
                      }else{
                        config_util.BgType.type = config_util.BgType.video;
                      }
                      /// 添加任务：执行已有的且名字和现在点击这个名字不同的脚本
                      /// 相同的就不执行
                      if(net_util.SpecialSubjoin.scriptSubJoinFileName == scriptName){
                        if(net_util.ActiveDynamicBgSpecialImgInfo.specialImgRelativePath.isEmpty || config_util.BgType.type == config_util.BgType.video){
                          return;
                        }
                        net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: net_util.ActiveDynamicBgSpecialImgInfo.specialImgFileName, doBefore: (){
                          net_util.Data.scriptFileRelativePath = net_util.ActiveDynamicBgSpecialImgInfo.specialImgRelativePath;
                        });
                      }else{
                        if(net_util.SpecialSubjoin.scriptSubJoinRelativePath.isEmpty){
                          return;
                        }
                        net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: net_util.SpecialSubjoin.scriptSubJoinFileName, doBefore: (){
                          net_util.Data.scriptFileRelativePath = net_util.SpecialSubjoin.scriptSubJoinRelativePath;
                        });
                      }
                    });
                  },
                  child: const Text("取消", textAlign: TextAlign.center,),
                )
            ),
            Expanded(
              /// 设置的按钮
              child: TextButton(
                /// 需要对当前的壁纸类型进行判断，现在定义视频仅仅能添加一个script脚本，特效有两种
                onPressed: () {
                  /// 首先需要开启
                  Win32Util.updateActiveBgWebHWnd();
                  if(Win32Util.hWndActiveDynamicBg == 0){
                    DataUtil.startActiveBgDynamicBgProc();
                    sleep(const Duration(milliseconds: 400));
                  }
                  // 表示此时点击的js是 subJoin
                  if(!isImg){
                    if(net_util.SpecialSubjoin.scriptSubJoinFileName.isNotEmpty){
                      /// 刷新
                      net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: "script.js", doBefore: (){
                        net_util.Data.scriptFileRelativePath = "/script.js";
                        javascript_util.rewriteJavaScript(javascript_util.reloadHtml);
                      });
                      /// 设置原有 video
                      if(net_util.ActiveDynamicBgVideoInfo.urlOrPath.isNotEmpty){
                        Timer(const Duration(milliseconds: 300), () {
                          DataUtil.setDynamicBgUrl(net_util.ActiveDynamicBgVideoInfo.urlOrPath);
                        });
                      }
                    }
                    /// 加载选中的 script
                    net_util.SpecialSubjoin.scriptSubJoinFileName = scriptName;
                    net_util.SpecialSubjoin.scriptSubJoinRelativePath = fileRelativePath;
                    net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: scriptName, doBefore: (){
                      net_util.Data.scriptFileRelativePath = fileRelativePath;
                    });
                    /// 开始鼠标监听，需要根据文件名判断监听的类型
                    // net_util.MouseAction.startMouseAction(actionType: net_util.MouseAction.getMouseAction(scriptName));
                    // 表示的是需要开启 img
                  }else{
                    config_util.BgType.type = config_util.BgType.specialImg;
                    // net_util.ActiveDynamicBgVideoInfo.urlOrPath = "";
                    /// 刷新
                    net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: "script.js", doBefore: (){
                      net_util.Data.scriptFileRelativePath = "/script.js";
                      javascript_util.rewriteJavaScript(javascript_util.reloadHtml);
                    });
                    /// 移除 video
                    net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: "script.js", doBefore: (){
                      net_util.Data.scriptFileRelativePath = "/script.js";
                      javascript_util.rewriteJavaScript(javascript_util.removeElement(javascript_util.videoId));
                    });
                    /// 添加任务：执行原有的脚本
                    net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: net_util.SpecialSubjoin.scriptSubJoinFileName, doBefore: (){
                      net_util.Data.scriptFileRelativePath = net_util.SpecialSubjoin.scriptSubJoinRelativePath;
                    });
                    /// 添加任务：刚选的脚本
                    net_util.CommunicationTaskQueueLoop.addMsg(action: net_util.ResponseActions.executeScript, data: scriptName, doBefore: (){
                      net_util.Data.scriptFileRelativePath = fileRelativePath;
                      net_util.ActiveDynamicBgSpecialImgInfo.specialImgFileName = scriptName;
                      net_util.ActiveDynamicBgSpecialImgInfo.specialImgRelativePath = fileRelativePath;
                    });
                  }
                },
                child: const Text("设置"),
              )
            ),
          ],
        )
    );
  }
}
