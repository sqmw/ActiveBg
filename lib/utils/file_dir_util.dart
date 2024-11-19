/// 0表示当前路径， -1 上一级路径 返回值的最后面没有 /
/// 最多到达磁盘目录
String getPathFromIndex(String path, int index){
  List<String> dirNames = path.split("\\");
  dirNames.removeLast();
  int len = dirNames.length;
  for(int i = 0;i < -index && i < len - 1;i++){
    dirNames.removeLast();
  }
  path = "";
  for(var dir in dirNames){
    path = "$path$dir/";
  }
  return path.substring(0, path.length - 1);
}

