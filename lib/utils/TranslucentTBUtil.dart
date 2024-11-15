import 'dart:io';

// 仅在 Windows 平台编译时导入 win32
class TranslucentTBUtil {
  static String translucentTBPath = "C:/Users/19519/Desktop/TranslucentTB/TranslucentTB.exe";

  // 判断这个任务栏透明的程序是否运行
  static bool isTranslucentTBRun() {
    // 在非 Windows 平台上始终返回 false
    if (!Platform.isWindows) {
      return false;
    }
    
    // 仅在 Windows 平台上执行的代码
    try {
      // int hTranslucentTB = FindWindow(nullptr, TEXT("TranslucentTB")); 
      // return hTranslucentTB != 0;
      return false;
    } catch (e) {
      print('Windows specific operation not available');
      return false;
    }
  }

  static void runTranslucentTB() {
    if (!Platform.isWindows) {
      print('TranslucentTB can only run on Windows');
      return;
    }
    
    Process.run(translucentTBPath, []);
  }
}
