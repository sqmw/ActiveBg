/// 0表示当前路径， -1 上一级路径 返回值的最后面有 /
/// 最多到达磁盘目录
String getPathFromIndex(String path, int index){
  List<String> dirNames = path.split("\\");
  dirNames.removeLast();
  print(dirNames);
  int len = dirNames.length;
  for(int i = 0;i < -index && i < len - 1;i++){
    dirNames.removeLast();
  }
  path = "";
  for(var dir in dirNames){
    path = "$path$dir/";
  }
  return path;
}