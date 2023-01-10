import 'dart:ffi';
import "package:win32/win32.dart";
/// 在程序开始执行的时候，就创建workerW
class Win32Util{
  static int _workerWHexHandle = 0;
  /// 表示的显示动态壁纸的窗口，需要维护这个句柄是最新的状态
  static int hWndActiveWeb = FindWindow(nullptr, TEXT("active_web_bg"));
  /// 深度搜索找到activeBg的句柄
  static void updateActiveBgWebHWnd(){
    hWndActiveWeb = FindWindow(nullptr, TEXT("active_web_bg"));
    if(hWndActiveWeb == 0){
      if(_workerWHexHandle == 0){
        createWorkerW();
      }
      hWndActiveWeb = FindWindowEx(Win32Util.enumGetWorkerWDescHandle(), 0, nullptr, TEXT("active_web_bg"));
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

  /// 如果workerW这个窗口已经存在，就不会创建
  static void createWorkerW(){
    _workerWHexHandle = enumGetWorkerWDescHandle();
    if(_workerWHexHandle != 0){
      return;
    }
    Pointer<IntPtr> result  = Pointer.fromAddress(0);
    SendMessageTimeout(FindWindow(TEXT("Progman"), nullptr),  0x052C, 0, 0, SMTO_NORMAL, 1000, result);
  }

  static bool setActiveBgToParentWorkerW({int parent = 0}){
    /// 去掉外边框
    updateActiveBgWebHWnd();
    int style = GetWindowLongPtr(hWndActiveWeb, GWL_STYLE);
    style = style & ~WS_CAPTION & ~WS_SYSMENU & ~WS_SIZEBOX;
    SetWindowLongPtr(hWndActiveWeb, GWL_STYLE, style);
    /// 设置父窗口以及全屏显示
    return SetParent(hWndActiveWeb, enumGetWorkerWDescHandle()) != 0 &&
    ShowWindow(hWndActiveWeb, SW_MAXIMIZE) != 0;
  }

  /// 销毁一个窗口在内存中的进程
  static void destroyActiveBgWin(){
    if(hWndActiveWeb == 0){
      updateActiveBgWebHWnd();
    }
    SendMessage(hWndActiveWeb,WM_DESTROY,0,0);
    /// 销毁之后置为 0
    hWndActiveWeb = 0;
  }
}
