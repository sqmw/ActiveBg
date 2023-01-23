import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'package:active_bg/utils/DataUtil.dart';
import 'package:ffi/ffi.dart';
import "package:win32/win32.dart";


/// 在程序开始执行的时候，就创建workerW
class Win32Util{
  static int _workerWHexHandle = 0;
  static bool isFullScreen = false;
  static const whRate = 99/54;
  static Pointer<RECT> activeBgBeforeRect = malloc<RECT>();
  /// 表示的显示动态壁纸的窗口，需要维护这个句柄是最新的状态
  static int hWndActiveWeb = FindWindow(nullptr, TEXT(DataUtil.activeDynamicBgTitle));
  /// 深度搜索找到activeBg的句柄
  static void updateActiveBgWebHWnd(){
    hWndActiveWeb = FindWindow(nullptr, TEXT(DataUtil.activeDynamicBgTitle));
    if(hWndActiveWeb == 0){
      if(_workerWHexHandle == 0){
        createWorkerW();
      }
      hWndActiveWeb = FindWindowEx(Win32Util.enumGetWorkerWDescHandle(), 0, nullptr, TEXT(DataUtil.activeDynamicBgTitle));
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

  /// 在 <第二个> workerW存在的情况下，获取第二个 _workerWHexHandle 以及 赋值
  static int enumGetWorkerWDescHandle(){
    final enumWinsFunc = Pointer.fromFunction<EnumWindowsProc>(_enumWindowsProc, 0);
    EnumWindows(enumWinsFunc, 0);
    return _workerWHexHandle;
  }

  /// 如果workerW这个窗口已经存在，就不会创建
  /// 如果这个窗口不存在，启动一次程序就只创建一次，这个函数只能调用一次
  static void createWorkerW(){
    _workerWHexHandle = enumGetWorkerWDescHandle();
    if(_workerWHexHandle != 0){
      return;
    }
    int count = 1;
    Pointer<IntPtr> result  = Pointer.fromAddress(0);
    SendMessageTimeout(FindWindow(TEXT("Progman"), nullptr),  0x052C, 0, 0, SMTO_NORMAL, 1000, result);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      SendMessageTimeout(FindWindow(TEXT("Progman"), nullptr),  0x052C, 0, 0, SMTO_NORMAL, 1000, result);
      count ++;
      if(count > 5 || enumGetWorkerWDescHandle() != 0){
        timer.cancel();
      }
    });
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
    PostMessage(hWndActiveWeb,WM_DESTROY,0,0);
    /// 销毁之后置为 0
    hWndActiveWeb = 0;
  }

  static int hWndActiveBg = FindWindow(nullptr, TEXT("active_bg"));

  /// 自定义窗口移动事件
  /// 此时的鼠标已经按下了
  static void moveActiveBgWindow() {
    Pointer<RECT> initRect = malloc<RECT>();
    GetWindowRect(Win32Util.hWndActiveBg, initRect);

    Pointer<POINT> pPointBefore = malloc<POINT>();
    Pointer<POINT> pPointAfter = malloc<POINT>();
    GetCursorPos(pPointBefore);
    Timer.periodic(const Duration(microseconds: 100), (timer) {
      // 此时表示处理按下的状态
      if(GetAsyncKeyState(VK_LBUTTON) < 0){
        GetCursorPos(pPointAfter);
        // 移动窗口
        MoveWindow(
          Win32Util.hWndActiveBg,
          initRect.ref.left + pPointAfter.ref.x - pPointBefore.ref.x,
          initRect.ref.top + pPointAfter.ref.y - pPointBefore.ref.y,
          // 宽和高
          initRect.ref.right-initRect.ref.left,
          initRect.ref.bottom - initRect.ref.top,
          0
        );
      }else{
        timer.cancel();
      }
    });
  }

  /// 设置窗口透明度
  static setActiveBgTransparent(int bAlpha ){
    assert(bAlpha >=0 && bAlpha <= 255);
    int wAttr = GetWindowLongPtr(hWndActiveBg, GWL_EXSTYLE);
    SetWindowLongPtr(hWndActiveBg, GWL_EXSTYLE, wAttr | WS_EX_LAYERED);
    // bAlpha 为 0 时，窗口是完全透明的。 bAlpha 为 255 时，窗口不透明。
    SetLayeredWindowAttributes(hWndActiveBg, 0, bAlpha, 0x02);
  }

  /// 设置窗口居中
  static setActiveBgCenter(){
    int screenWidth = GetSystemMetrics(SM_CXFULLSCREEN);
    int screenHeight = GetSystemMetrics(SM_CYFULLSCREEN);
    MoveWindow(hWndActiveBg, (screenWidth * 0.1).toInt() , (screenHeight * 0.1).toInt(), (screenWidth * 0.8).toInt(),  (screenHeight * 0.8).toInt(), 1);
  }

  /// 设置窗口的全屏显示以及退出全屏
  static void setFullScreenOrOutFullScreen(){
    /// SW_RESTORE
    /// 9	Activates and displays the window. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when restoring a minimized window.
    if(isFullScreen){
      ShowWindow(hWndActiveBg, SW_RESTORE);
    }else{
      /// 这个函数调用之后就会给系统置于maximize状态
      ShowWindow(hWndActiveBg, SW_MAXIMIZE);
    }
    isFullScreen = !isFullScreen;
  }
}
