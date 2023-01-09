import 'dart:ffi';
import "package:win32/win32.dart";
/// 在程序开始执行的时候，就创建workerW
class Win32Util{
  static late final int _workerWHexHandle;
  /// 表示的显示动态壁纸的窗口
  static int _hWndActiveWeb = FindWindow(nullptr, TEXT("active_web_bg"));
  static void updateActiveBgWebHWnd(){
    _hWndActiveWeb = FindWindow(nullptr, TEXT("active_web_bg"));
    if(_hWndActiveWeb == 0){
      if(_workerWHexHandle == 0){
        createWorkerW();
      }
      _hWndActiveWeb = FindWindowEx(_workerWHexHandle, 0, nullptr, TEXT("active_web_bg"));
    }
  }
  static int _enumWindowsProc(int hWnd,int lParam){
    /// print(hWnd.toRadixString(16));
    int pHWnd = FindWindowEx(hWnd, 0, TEXT("SHELLDLL_DefView"), nullptr);
    if(pHWnd != 0){
      //print(int.parse(hWnd.toString(),radix: 16));
      _workerWHexHandle = FindWindowEx(0, hWnd, nullptr, nullptr);
      //表示可以退出了
      return FALSE;
    }
    //表示继续执行
    return TRUE;
  }

  static int enumGetWorkerWDescHandle(){
    final enumWinsFunc = Pointer.fromFunction<EnumWindowsProc>(_enumWindowsProc, 0);
    EnumWindows(enumWinsFunc, 0);
    return _workerWHexHandle;
  }

  /// 如果没有workerW这个窗口的话，就基本没什么影响
  static void createWorkerW(){
    Pointer<IntPtr> result  = Pointer.fromAddress(0);
    SendMessageTimeout(FindWindow(TEXT("Program"), nullptr),  0x052C, 0, 0, SMTO_NORMAL, 1000, result);
  }

  static void setActiveBgToParent({int parent = 0}){
    /// 去掉外边框
    int style = GetWindowLongPtr(_hWndActiveWeb, GWL_STYLE);
    style = style & ~WS_CAPTION & ~WS_SYSMENU & ~WS_SIZEBOX;
    SetWindowLongPtr(_hWndActiveWeb, GWL_STYLE, style);
    /// 设置父窗口以及全屏显示
    SetParent(_hWndActiveWeb, parent);
    ShowWindow(_hWndActiveWeb, SW_MAXIMIZE);
  }

  /// 销毁一个窗口在内存中的进程
  static void destroyActiveBgWin(){
    if(_hWndActiveWeb == 0){
      updateActiveBgWebHWnd();
    }
    SendMessage(_hWndActiveWeb,WM_DESTROY,0,0);
  }
}
