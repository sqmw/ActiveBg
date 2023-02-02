import 'package:active_bg/interfaces/Preview.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html_dom;

import 'package:active_bg/utils/DataUtil.dart';
import '../viewUtils/ImageView.dart';
import 'DynamicSearch.dart';
import 'package:active_bg/utils/NetUtil.dart' as net_util show dynamicBgVideoDownload;
/// 动态壁纸的显示推荐和分类的部分，分类和推荐共同使用一个Future，因此封装在一起

class RecommendAndClassifySet extends StatefulWidget {
  const RecommendAndClassifySet({Key? key}) : super(key: key);

  @override
  State<RecommendAndClassifySet> createState() => _RecommendAndClassifySetState();
}

class _RecommendAndClassifySetState extends State<RecommendAndClassifySet> implements Preview{
  late final List<Widget> _classificationList = [];
  final List<Widget> _recommendDynamicBgList = [];
  bool _dataLoaded = false;

  void loadWidgetInfo(dynamic data){
    //DataUtil.dio.options.headers = {};
    /// 获取推荐
    // region
    // log("${response.data.toString().length}--->length");
    List<html_dom.Element> recommendListInfo = DataUtil.getEleListFromStrBySelector("$data", DataUtil.QUERY_VIDEO_PAGE_LIST);
    /// log("${recommendListInfo}");
    /// print(element.innerHtml);
    for (var element in recommendListInfo) {
      _recommendDynamicBgList.add(ListTile(
        onTap: (){
          preview(data: "${element.children[0].attributes["src"]}");
        },
        title: Image(
          /// 这里使用静态的，防止太大的内存开销
          image: NetworkImage("${element.children[1].attributes["src"]}"),
        ),
        subtitle: Row(
          children: [
            Expanded(
                child: TextButton(
                  onPressed: () {
                    DataUtil.dio.get("${element.attributes["href"]}")
                      .then((res){
                      html_dom.Element videoEle = DataUtil.getEleListFromStrBySelector("${res.data}", DataUtil.QUERY_VIDEO)[0];
                      net_util.dynamicBgVideoDownload(videoUrl: videoEle.attributes["src"]!, imgUrl: "${element.children[0].attributes["src"]}");
                    });
                  },
                  child: const Text("下载"),
                )
            ),
            Expanded(
                child: TextButton(
                  onPressed: () {
                    //log("${element.attributes["href"]}");
                    DataUtil.dio.get("${element.attributes["href"]}")
                    .then((res){
                      html_dom.Element videoEle = DataUtil.getEleListFromStrBySelector("${res.data}", DataUtil.QUERY_VIDEO)[0];
                      //log(videoEle.attributes["src"]!);
                      DataUtil.setDynamicBgUrl(videoEle.attributes["src"]!);
                    })
                    .catchError((err){

                    });
                  },
                  child: const Text("设为壁纸"),
                )
            ),
          ],
        ),
      ));
    }
    //endregion
    /// 获取分类
    List<html_dom.Element> classificationListInfo = DataUtil.getEleListFromStrBySelector("$data", DataUtil.QUERY_TYPE);
    for (var element in classificationListInfo) {
      _classificationList.add(ListTile(
        onTap: (){
          Navigator.push(context,MaterialPageRoute(builder: (context){
            return DynamicSearchSet("${element.attributes['href']}");
          }));
        },
        title: const Image(image: NetworkImage("https://tuapi.eees.cc/api.php?category=dongman&type=302")),
        subtitle: Text(element.text,textAlign: TextAlign.center,),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(_dataLoaded){
      return SetContent(recommendDynamicBgList: _recommendDynamicBgList, classificationList: _classificationList);
    }
    return FutureBuilder(
    //DataUtil.dio.options.headers = DataUtil.DYNAMIC_HEADERS;
    future: DataUtil.dio.get(DataUtil.DYNAMIC_BASE_URL),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasData){
            loadWidgetInfo(snapshot.data);
            _dataLoaded = true;
            return SetContent(recommendDynamicBgList: _recommendDynamicBgList, classificationList: _classificationList);
          }else{
            return Center(
              child: Text("${snapshot.error}"),
            );
          }
        }else{
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  void preview({data}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context){
          return ImageView(
            image: Image(
              fit: BoxFit.fill,
              image: NetworkImage(data),
            ),
          );
        }
    );
  }
}

class SetContent extends StatelessWidget {
  SetContent({required this.recommendDynamicBgList,required this.classificationList ,Key? key}) : super(key: key);
  late Size _size;
  List<Widget> recommendDynamicBgList;
  List<Widget> classificationList;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;

    return SizedBox(
        width: _size.width,
        height: _size.height*1,
        child: ListView(
          children: [
            const Divider(
              color: Colors.red,
              thickness: 3,
            ),
            const Text("推荐",textAlign: TextAlign.center,),
            const Divider(
              color: Colors.red,
              thickness: 3,
            ),
            SizedBox(
              height: _size.height * 1 - 50,
              width: _size.width,
              child:GridView.count(
                childAspectRatio: 99/(54 + 9),
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                children: recommendDynamicBgList,
              ),
            ),
            const Divider(
              color: Colors.red,
              thickness: 3,
            ),
            /// 分类
            const Text("分类", textAlign: TextAlign.center,),
            const Divider(
              color: Colors.red,
              thickness: 3,
            ),
            SizedBox(
              width: _size.width,
              height: _size.width / 4 * 54/99 * (classificationList.length / 4).ceil() + 100,
              child:GridView.count(
                childAspectRatio: 99/54,
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                children: classificationList,
              ),
            ),
          ],
        )
    );
  }
}

