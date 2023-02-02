import 'package:active_bg/mixins/UriAnalysis.dart';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

class LocalFileOrNetVideo extends StatefulWidget {
  const LocalFileOrNetVideo({Key? key}) : super(key: key);

  @override
  State<LocalFileOrNetVideo> createState() => _LocalFileOrNetVideoState();
}

class _LocalFileOrNetVideoState extends State<LocalFileOrNetVideo> with UriAnalysis{

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(size.width * 0.2, 0, size.width * 0.2, 0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: ()async{
                    final XFile? file = await openFile(initialDirectory: "${DataUtil.BASE_PATH}/videos/mp4");
                    /// 防止没有选择文件
                    if(file == null ||file.path.isEmpty){
                      return;
                    }
                    textEditingController.text = file.path;
                    DataUtil.setDynamicBgUrl(textEditingController.text.trim());
                  },
                  icon: Icon(Icons.file_open, color: Theme.of(context).primaryColor,),
                )
              ),
              Expanded(
                  flex: 12,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "请输入本地mp4地址/网络mp4链接"
                    ),
                    autofocus: true,
                    controller: textEditingController,
                  )
              ),
              Expanded(
                  flex: 3,
                  child: TextButton(
                    onPressed: () {
                      if(textEditingController.text.isEmpty){
                        return;
                      }
                      DataUtil.setDynamicBgUrl(textEditingController.text.trim());
                    },
                    child: const Text("设置"),
                  )
              )
            ],
          ),
        )
      ],
    );
  }
}
