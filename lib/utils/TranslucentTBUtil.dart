import 'dart:ffi';
import 'dart:io';
import 'package:win32/win32.dart';


class TranslucentTBUtil{
  static String translucentTBPath = "C:/Users/19519/Desktop/TranslucentTB/TranslucentTB.exe";
  static bool isTranslucentTBRun(){
    int hTranslucentTB = FindWindow(nullptr,TEXT("TranslucentTB"));
    if(hTranslucentTB != 0){
      return true;
    }
    return false;
  }

  static void runTranslucentTB(){
    Process.run(translucentTBPath, []);
  }
}
