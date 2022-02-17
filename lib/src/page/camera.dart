import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import '../../main.dart';

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);

  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  late CameraController controller;
  late final interpreter;
  late CameraImage cameraImage;

  bool isDetecting = false;
  var output;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      loadModel().then((_) {
        controller.startImageStream((image) {
          if (!isDetecting) {
            isDetecting = true;
            cameraImage = image;
            interpreter.allocateTensors();
            print(interpreter.getInputTensors());
            print(interpreter.getOutputTensors());

            // image => tensorflow 모델의 input type으로 변환하는 코드 필요
            runModel();


          }
        });
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  loadModel() async {
    interpreter =
        await tfl.Interpreter.fromAsset('models/face_landmark.tflite');
  }

  runModel() async {
    Map<String, Object> inputs = HashMap();
    Map<String, Object> outputs = HashMap();
    interpreter.run(inputs, outputs);
    // 192x192

    print("input: "+inputs.toString());
    print("output: "+outputs.toString());

    // 가져온 output을 바탕으로 해당 위치에 원하는 프레임에 사진? 필터? 씌우는 코드

  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(controller),
    );
  }
}
