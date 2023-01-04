import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:active_bg/interfaces/ChangeBgInterval.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'dart:developer' as developer;

import '../../../utils/DataUtil.dart';

class SelfDefine extends StatefulWidget {
  const SelfDefine({Key? key}) : super(key: key);

  @override
  State<SelfDefine> createState() => _SelfDefineState();
}

class _SelfDefineState extends State<SelfDefine> implements ChangeBgInterval{
  bool _changeInterval = false;
  bool _imgFromLocal = false;
  Duration _duration = const Duration(seconds: 10);
  String? _resourcePath = "${DataUtil.BATH_PATH}/image";
  final List<String> _imagePathList = [];
  Timer? _tLocal;
  Timer? _tNet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: ListTile(
            leading: const Text("定时切换",textAlign: TextAlign.end,),
            trailing: Checkbox(
              value: _changeInterval,
              onChanged: (bool? value) {
                setState(() {
                  _changeInterval = !_changeInterval;
                  developer.log("_changeInterval--${_changeInterval},${value}");
                  changeBgIntervalLocal();
                  changeBgIntervalOnNet();
                });
              },
            ) ,
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  leading: const Text("网络资源"),
                  title: Radio(
                    value: false,
                    groupValue: _imgFromLocal,
                    onChanged: (bool? value) {
                      developer.log("_imgFromLocal: ${value}");
                      setState(() {
                        _imgFromLocal = value!;
                        changeBgIntervalOnNet();
                      });
                      developer.log("${value}");
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: const Text("本地图片"),
                  title: Radio(
                    value: true,
                    groupValue: _imgFromLocal,
                    onChanged: (bool? value) {
                      developer.log("_imgFromLocal: ${value}");
                      setState(() {
                        _imgFromLocal = value!;
                        changeBgIntervalLocal();
                      });
                      developer.log("${value}");
                    },
                  ),
                ),
              ),
            ],
          )
        ),
        Expanded(
          child: ListTile(
            leading: const Text("本地地址"),
            title: InkWell(
              onTap: ()async{
                _resourcePath = await FileSelectorPlatform.instance.getDirectoryPath();
                setState(() {
                  changeBgIntervalLocal();
                });
              },
              child: Text("$_resourcePath"),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: ListTile(
            leading: const Text("切换间隔"),
            title: InkWell(
              onTap: (){
                showModalBottomSheet(
                  context: context,
                  builder: (context){
                    return CupertinoTimerPicker(
                      initialTimerDuration: _duration,
                      onTimerDurationChanged: (Duration value) {
                        _duration = value;
                        setState(() {
                          changeBgIntervalLocal();
                        });
                      });
                });
              },
              child: Text(
                "${_duration}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            )
          ),
        ),
      ],
    );
  }

  Future<void> loadImageList()async{
    Directory directory = Directory(_resourcePath!);
    directory.list().toList()
      .then((value){
        value.forEach((element) {
          if(FileSystemEntity.isFileSync(element.absolute.path)){
            _imagePathList.add(element.absolute.path);
          }
        });
        return;
    });
  }
  ///该函数经过验证没有问题验证
  @override
  void changeBgIntervalOnNet() {
    // TODO: implement changeBgInterval
    _tNet?.cancel();
    if(_changeInterval && !_imgFromLocal){
      developer.log("net");
      Map<String, dynamic> _resData;
      _tNet = Timer.periodic(_duration, (timer) async {
        if(!_changeInterval || _imgFromLocal){
          timer.cancel();
        }
        int uniTimeId = DataUtil.getNowMicroseconds();
        _resData = json.decode("${await DataUtil.dio.get("https://tuapi.eees.cc/api.php?category=dongman&type=json")}");
        developer.log("${_resData}");
        DataUtil.dio.download(_resData["img"], "${DataUtil.BATH_PATH}/image/${uniTimeId}.${_resData["format"]}")
            .then((value){
          Timer(const Duration(milliseconds: 10),(){
            DataUtil.changeBackground("${DataUtil.BATH_PATH}/image/$uniTimeId.${_resData["format"]}".toNativeUtf8());
          });
        });
      });
    }
  }

  @override
  void changeBgIntervalLocal() async{
    // TODO: implement changeBgIntervalLocal
    _tLocal?.cancel();
    if(_changeInterval && _imgFromLocal){
      developer.log("local");
      //加载对应文件夹里面的图片
      await loadImageList();
      int i = 0;
      _tLocal = Timer.periodic(_duration, (timer) {
        if(!_changeInterval || !_imgFromLocal){
          timer.cancel();
        }
        developer.log("local: ${i%_imagePathList.length}");
        DataUtil.changeBackground(_imagePathList[i++%_imagePathList.length].toNativeUtf8());
      });
    }
  }
}
