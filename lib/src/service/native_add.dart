import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

// Steps
// Open library -> Look up function -> Call function
// C function signatures
// C에서 쓰는 자료형은 ffi.(Type) 으로 사용
typedef _version_func = ffi.Pointer<Utf8> Function();
typedef _process_image_func = ffi.Void Function(
    ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);

// Dart function signatures
// 이 부분은 꼭 필요한 것은 아니고, 코드를 예쁘게 짜기 위해서 함수 타입을 typedef 키워드로 지정해놓은 것.
// https://www.youtube.com/watch?v=2MMK7YoFgaA 참고
typedef _VersionFunc = ffi.Pointer<Utf8> Function();
typedef _ProcessImageFunc = void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);

// Getting a library that holds needed symbols
ffi.DynamicLibrary _lib = Platform.isAndroid
    ? ffi.DynamicLibrary.open('libnative_opencv.so')
    : ffi.DynamicLibrary.process();

// Looking for the functions
// lookup은 symbol(변수나 함수)의 주소를 메모리에서 읽어오는 것. 쉽게 말해서 symbol을 가져온다고 생각하면 된다.
final _VersionFunc _version =
    _lib.lookup<ffi.NativeFunction<_version_func>>('version').asFunction();
final _ProcessImageFunc _processImage = _lib
    .lookup<ffi.NativeFunction<_process_image_func>>('process_image')
    .asFunction();

// _version 함수의 리턴값은 C타입이라 Dart String으로 변환해줌
String opencvVersion() {
  return _version().toDartString();
}

// toNativeUtf8에서 Native는 C언어를 의미함. android나 ios 의미 X
void processImage(ProcessImageArguments args) {
  _processImage(args.inputPath.toNativeUtf8(), args.outputPath.toNativeUtf8());
}

class ProcessImageArguments {
  final String inputPath;
  final String outputPath;

  ProcessImageArguments(this.inputPath, this.outputPath);
}
