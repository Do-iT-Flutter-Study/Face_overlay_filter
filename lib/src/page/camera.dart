import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:practice1/src/utils/image_utils.dart';

import '../../main.dart';
import '../model/face_mesh.dart';
import '../model/face_mesh_painter.dart';
import '../utils/isolate_utils.dart';

// 현재 compute와 isolate와 같은 백그라운드 메소드에 대해서 공부 중인 코드입니다.
// https://github.com/JaeHeee/FlutterWithMediaPipe/
// 이 분의 깃허브를 참고하면 isolateUtils.dart 파일이 있습니다. 이 파일과 구글링을 참고하면 될 것 같습니다.

// 1. 카메라의 스트림을 가져와서 매 프레임마다 이미지를 가져옵니다.
// 2. 가져온 이미지를 FaceMesh 모델에 입력값으로 넣어주어 분석합니다.
// 3. 분석값은 x, y, z 방향마다 468개의 landmark를 줍니다. 이 값 중, 여러분이 원하는 위치를 가져오면 됩니다.
// 4. 가져온 landamark 값을 바탕으로 오버레이 이미지를 위치시킵니다.

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);

  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  // cameraController는 camera action을 handling 하기 위한 class입니다.
  late CameraController _cameraController;

  // cameraController를 초기화 하기 위한 함수 변수입니다. 변수로 만드는 이유는 전면 / 후면 카메라로 변환하기 위함입니다.
  Future<void>? _initCameraControllerFuture;

  // 전면 / 후면 카메라에 대한 int 변수입니다. 0 = 후면, 1 = 전면
  int cameraIndex = 0;

  // landmark 분석값을 담기 위한 변수입니다.
  Map<String, dynamic>? results = <String, dynamic>{};

  // 얼굴이 감지 됐을 때를 판단하기 위한 변수인데, 지금까지는 굳이...?
  bool isDetecting = false;

  // FaceMesh 모델을 멀티쓰레드 환경에서 실행하기 위한 변수
  final IsolateUtils _isolateUtils = IsolateUtils();
  final FaceMesh faceMesh = FaceMesh();

  // StatefulWidget의 초기 상태를 정해주면서 초기화를 해줘야하는 변수들도 같이 초기화 해줌
  @override
  void initState() {
    super.initState();
    _isolateUtils.initIsolate();
    _initCamera();
  }

  // Camera 초기 상태를 정해주는 함수
  Future<void> _initCamera() async {
    // faceMesh = FaceMesh();
    // 사용가능한 camera list를 가져옵니다.
    // cameras[0] = 후면 카메라, cameras[1] = 전면 카메라, resoultionPreset은 Frame 관련 변수입니다.
    // cameraController.initialize().then 코드 블록 안에 camera handling 하는 로직을 작성하면 됩니다.
    final cameras = await availableCameras();
    _cameraController =
        CameraController(cameras[cameraIndex], ResolutionPreset.max);
    _initCameraControllerFuture = _cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});

      _cameraController.startImageStream((image) async {
        // image 값이 계속 변화하면서 UI를 변경
        _isolateSpawn(image);
        // results = await compute(_predict, image);
      });
      // setState(() {});
    });
  }

  // 이 클래스의 화면을 벗어나는 경우, 메모리를 해제합니다.
  @override
  void dispose() {
    _isolateUtils.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  // void _predict(imglib.Image imageInput) async {
  //   results = _faceMesh.predict(imageInput);
  // }

  // 전면 / 후면카메라 바꾸는 함수
  void _onSwitchCamera() async {
    cameraIndex = cameraIndex == 0 ? 1 : 0;
    await _initCamera();
  }

  @override
  Widget build(BuildContext context) {
    // 카메라 화면의 크기를 정해주는건데, 자유롭게 바꾸면 됩니다.
    final screenSize = MediaQuery.of(context).size;
    final double _ratio =
        screenSize.width / _cameraController.value.previewSize!.height;

    // 카메라 화면을 가져오려면 비동기 작업으로 처리해야합니다.
    // 따라서 카메라 화면을 불러오기 전까지는 로딩 중인 화면을 보여주고, 로딩이 다 되면 CameraPrieview(_cameraController)를 통해
    // 카메라 화면을 가져옵니다.
    // 카메라 화면은 Stack으로 이루어져 있는데, 배경이 되는 화면은 카메라 화면이고 그 위에 landmark든 overlay image든 얹으면 됩니다.
    return FutureBuilder(
        future: _initCameraControllerFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_cameraController),
                // landmark가 제대로 찍히는 것을 확인 했으면
                // 밑에 CustomPoaint(FaceMeshPainter) 이 코드는 주석처리 혹은 지우고
                // results?['point'][index] 이런 방식으로 원하는 위치를 가져와서 그 위치에 맞게 이미지를 불러온다.
                // if(index == noseIndex)
                // Positioned(
                //     top: results?['point'][index], // dx
                //     bottom: 0,
                //     left: results?['point'][index], // dy
                //     right: 0,
                //     child: Image.asset('path')),
                CustomPaint(
                  painter: FaceMeshPainter(
                    points: results?['point'] ?? [],
                    ratio: _ratio,
                  ),
                ),
                OutlinedButton(
                    onPressed: _onSwitchCamera, child: Text("Switch"))
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
    // MaterialApp(
    //     home: Stack(
    //   children: [
    //     CameraPreview(_cameraController),
    //     // landmark가 제대로 찍히는 것을 확인 했으면
    //     // 밑에 CustomPoaint(FaceMeshPainter) 이 코드는 주석처리 혹은 지우고
    //     // results?['point'][index] 이런 방식으로 원하는 위치를 가져와서 그 위치에 맞게 이미지를 불러온다.
    //     // if(index == noseIndex)
    //     // Positioned(
    //     //     top: results?['point'][index], // dx
    //     //     bottom: 0,
    //     //     left: results?['point'][index], // dy
    //     //     right: 0,
    //     //     child: Image.asset('path')),
    //     Center(
    //         child: CustomPaint(
    //       painter: FaceMeshPainter(
    //         points: results?['point'] ?? [],
    //         ratio: _ratio,
    //       ),
    //     )),
    //     OutlinedButton(onPressed: _onSwitchCamera, child: Text("Switch"))
    //   ],
    // ));
  }

  // 멀티쓰레드 환경에서 실행할 함수를 정의합니다.
  // Handler에 runFaceMesh 메소드를 넣어서, FaceMesh 모델을 메인쓰레드와 분리하여 실행합니다.
  void _isolateSpawn(CameraImage image) async {
    final responsePort = ReceivePort();
    Map<String, dynamic> params = {
      'detectorAddress': faceMesh.getAddress,
      'cameraImage': image
    };

    _isolateUtils.sendMessage(
      runFaceMesh,
      _isolateUtils.sendPort,
      responsePort,
      params: params,
    );

    final result = await responsePort.first;
    setState(() {
      results = result;
    });
  }

// void _compute() async {
//   final result = await compute(handler, _url);
//   setState(() {
//     _computeResult = result;
//   });
// }
//
// static Future<dynamic> handler(String url) async {
//   final response = await http.get(Uri.parse(url));
//   final json = jsonDecode(response.body);
//
//   return json['results'][0]['email'];
// }
}
