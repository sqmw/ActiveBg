import 'dart:async';
import 'dart:convert';

import 'package:active_bg/component/viewUtils/ImageView.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../../../utils/DataUtil.dart';
import '../../viewUtils/NetCheck.dart';

class StaticRecommend extends StatefulWidget {
  const StaticRecommend({Key? key}) : super(key: key);

  @override
  State<StaticRecommend> createState() => _StaticRecommendState();
}
/// @Author 1951918362
/// 还需要验证图片加载是否正确
class _StaticRecommendState extends State<StaticRecommend> {
  final List<Map<String,dynamic>> _imageInfoList = [];
  final ScrollController _scrollController = ScrollController();
  final List<String> _savedImgNameList = [];
  int _imgCou = DataUtil.IMAGE_COUNT;
  bool _canLoad = true;
  Future? future;
  @override
  void initState() {
    developer.log("init");
    super.initState();
    developer.log("load finished");
    _scrollController.addListener(() {
      developer.log("${_scrollController.offset/_scrollController.position.maxScrollExtent}---max");
      if(_scrollController.offset/_scrollController.position.maxScrollExtent == 1){
        if(_imageInfoList.length % DataUtil.IMAGE_COUNT != 0 || _imageInfoList.isEmpty){
          showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title:const Text("提示"),
                content:const Text("加载中，请稍后！"),
                actions: [
                  ElevatedButton(onPressed: (){
                    Navigator.of(context).pop();
                  },
                      child: const Text("确定")
                  ),
                  ElevatedButton(onPressed: (){
                    Navigator.of(context).pop();
                  },
                      child: const Text("取消")
                  )
                ],
              );
            }
          );
          return;
        }
        if(_canLoad){
          _canLoad = !_canLoad;
          _imgCou += DataUtil.IMAGE_COUNT;
          setState(() {});
          Timer(const Duration(seconds: 1),(){
            _canLoad = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log("build");
    return NetCheck(child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio:16/10,
        ),
        itemCount: _imgCou,
        // 如果已经有了，就返回已经有了的，否则返回新的
        itemBuilder: (context,index){
          developer.log("index: $index");
          if(index + DataUtil.IMAGE_COUNT < _imgCou){
            // 这里必须JSON化
            future = Future.sync(() => json.encode(_imageInfoList[index]));
          }else{
            future = DataUtil.dio.get("https://tuapi.eees.cc/api.php?category=dongman&type=json&r=${DataUtil.getRandomInt()}");
          }
          return FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if(snapshot.connectionState == ConnectionState.done){
                if(snapshot.hasData){
                  //var imgInfo = json.decode("${snapshot.data}");
                  var imgInfo = json.decode("${snapshot.data}");
                  if(index + DataUtil.IMAGE_COUNT >= _imgCou){
                    _imageInfoList.add(imgInfo);
                  }
                  developer.log("${_imageInfoList.length}");
                  developer.log(imgInfo["img"]);
                  return ListTile(
                    onTap: (){
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context){
                            return ImageView(
                              image: Image(
                                image: NetworkImage(imgInfo["img"]),
                              ),
                            );
                          });
                    },
                    title: Image(
                      image: NetworkImage(imgInfo["img"]),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                            child: TextButton(
                              onPressed: () {
                                developer.log("下载");
                              },
                              child: const Text("下载"),
                            )
                        ),
                        Expanded(
                            child: TextButton(
                              onPressed: () {
                                developer.log("set: ${index}");
                                int uniTimeId = DataUtil.getNowMicroseconds();
                                DataUtil.dio.download(imgInfo["img"], "${DataUtil.BASE_PATH}/images/${uniTimeId}.${imgInfo["format"]}")
                                    .then((value){
                                  _savedImgNameList.add("${uniTimeId}.${imgInfo["format"]}");
                                  Timer(const Duration(milliseconds: 10),(){
                                    DataUtil.changeStaticBackground("${DataUtil.BASE_PATH}/images/$uniTimeId.${imgInfo["format"]}");
                                  });
                                });
                              },
                              child: const Text("设为壁纸"),
                            )
                        ),
                      ],
                    ),
                  );
                }
                else{
                  return Text("${snapshot.error}");
                }
              }else{
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        }
    ),);
  }
}

