import 'dart:math';
import 'dart:ffi' as ffi;
import 'package:dio/dio.dart';
import 'package:ffi/ffi.dart';

typedef ChangeBackgroundFFI = ffi.Void Function(ffi.Pointer<Utf8>);
typedef ChangeBackground = void Function(ffi.Pointer<Utf8>);


class DataUtil{
  static const String BATH_PATH = "F:/language/flutter/ActiveBg/lib/assets";
  static final _dylib = ffi.DynamicLibrary.open("lib/dll/bg_01.dll");
  static final ChangeBackground changeBackground = _dylib.lookup<ffi.NativeFunction<ChangeBackgroundFFI>>("changeBackground").asFunction();
  static final Dio dio = Dio();
  static const IMAGE_COUNT = 9;
  static final Random _random = Random();
  static int getRandomInt(){
    return _random.nextInt(100);
  }

  static int getNowMicroseconds(){
    return DateTime.now().microsecondsSinceEpoch;
  }
}

void main(){
  final a = 1;
}