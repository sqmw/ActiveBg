import 'package:active_bg/utils/DataUtil.dart';

void main()async{
  List list = await DataUtil.getImgAbsUrls(ques: "壁纸", start: 150);
  print(list);
}