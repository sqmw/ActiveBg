import 'dart:async';
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
  Duration _duration = const Duration(seconds: 30);
  String? _resourcePath = "${DataUtil.BATH_PATH}/image";
  List<String> _imagePathList = [];

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
                setState(() {});
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
                        setState(() {});
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
  ///该函数还未验证
  @override
  void changeBgIntervalOnNet() {
    // TODO: implement changeBgInterval
    if(_changeInterval && !_imgFromLocal){
      int i = 0;
      Timer.periodic(_duration, (timer) {
        DataUtil.changeBackground(_imagePathList[i++%_imagePathList.length].toNativeUtf8());
      });
    }
  }

  @override
  void changeBgIntervalLocal() {
    // TODO: implement changeBgIntervalLocal
    if(_changeInterval && _imgFromLocal){
      Directory directory = Directory(_resourcePath!);
      directory.list().toList()
          .then((value){
        value.forEach((element) {
          developer.log("${element.absolute}");
        });
      });
    }
  }
}
