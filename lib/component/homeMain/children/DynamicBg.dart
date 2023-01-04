import 'package:flutter/material.dart';

class DynamicBg extends StatefulWidget {
  const DynamicBg({Key? key}) : super(key: key);

  @override
  State<DynamicBg> createState() => _DynamicBgState();
}

class _DynamicBgState extends State<DynamicBg> {
  late TextEditingController _keyTextController;
  late Size _size;
  late final List<Widget> _classificationList;
  final List<Widget> _recommendDynamicBgList = [

  ];


  @override
  void initState() {
    super.initState();
    _keyTextController = TextEditingController();
    for (int i = 0;i < 9; i++){
      _recommendDynamicBgList.add(const ListTile(
        title: Image(
          image: NetworkImage("https://img-baofun.zhhainiao.com/pcwallpaper_ugc/live/54f0e5d178be42f82ea66270f70efcfe.mp4.jpg?x-oss-process=image/resize,type_6,m_fill,h_170,w_301"),
        ),
      ));
    }
    //region
    _classificationList = const [
      Expanded(
        child: ListTile(
          title: Image(
            image: NetworkImage("https://img-baofun.zhhainiao.com/pcwallpaper_ugc/live/54f0e5d178be42f82ea66270f70efcfe.mp4.jpg?x-oss-process=image/resize,type_6,m_fill,h_170,w_301"),
          ),
          subtitle: Text("风景"),
        )
      ),
      Expanded(
          child: ListTile(
            title: Image(
              image: NetworkImage("https://img-baofun.zhhainiao.com/pcwallpaper_ugc/live/54f0e5d178be42f82ea66270f70efcfe.mp4.jpg?x-oss-process=image/resize,type_6,m_fill,h_170,w_301"),
            ),
            subtitle: Text("4K"),
          )
      ),
      Expanded(
          child: ListTile(
            title: Image(
              image: NetworkImage("https://img-baofun.zhhainiao.com/pcwallpaper_ugc/live/54f0e5d178be42f82ea66270f70efcfe.mp4.jpg?x-oss-process=image/resize,type_6,m_fill,h_170,w_301"),
            ),
            subtitle: Text("动漫"),
          )
      ),
      Expanded(
          child: ListTile(
            title: Image(
              image: NetworkImage("https://img-baofun.zhhainiao.com/pcwallpaper_ugc/live/54f0e5d178be42f82ea66270f70efcfe.mp4.jpg?x-oss-process=image/resize,type_6,m_fill,h_170,w_301"),
            ),
            subtitle: Text("美女"),
          )
      ),
    ];
    //endregion
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        /// 搜索
        Center(
          child: SizedBox(
            width: _size.width * 0.8,
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                suffix: IconButton(
                  onPressed: () {  },
                  icon: const Icon(Icons.search),
                )
              ),
              controller: _keyTextController,
            ),
          ),
        ),
        /// 推荐
        Text("推荐"),
        Container(
          height: _size.height * 1,
          width: _size.width,
          child:GridView.count(
            crossAxisCount: 3,
            children: _recommendDynamicBgList,
          ),
        ),
        /// 分类
        Text("分类"),
        Container(
          width: _size.width,
          height: _size.height * 0.4,
          child: Row(
            children: _classificationList,
          ),
        ),
      ],
    );
  }
}
