import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import './src/app.dart';

late Directory tempDir;
late List<CameraDescription> cameras;

String get tempPath => '${tempDir.path}/doitlogo-removebg.jpg';

Future<void> main() async {
  // 위에 두 줄은 카메라 권환 가져오기
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(const MyApp());
  // 밑에 한 줄은 c++ 코드 가져오기
  getTemporaryDirectory().then((dir) => tempDir = dir);
}
