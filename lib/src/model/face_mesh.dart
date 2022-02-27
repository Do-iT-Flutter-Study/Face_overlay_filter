import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import '../utils/image_utils.dart';
import 'ai_model.dart';


// ignore: must_be_immutable
// faceMesh model에 관한 코드입니다.
// 출처 : https://github.com/JaeHeee/FlutterWithMediaPipe/
// predict 함수를 관심있게 보시면 됩니다.
class FaceMesh extends AiModel {
  late InterpreterOptions _interpreterOptions;

  FaceMesh({this.interpreter}) {
    loadModel();
  }

  final int inputSize = 192;

  @override
  Interpreter? interpreter;

  @override
  List<Object> get props => [];

  @override
  int get getAddress => interpreter!.address;

  @override
  Future<void> loadModel() async {
    try {
      final _interpreterOptions = InterpreterOptions();

      interpreter ??= await Interpreter.fromAsset('models/face_landmark.tflite',
          options: _interpreterOptions);
      print('interpreter initialized');
      final outputTensors = interpreter!.getOutputTensors();

      outputTensors.forEach((tensor) {
        outputShapes.add(tensor.shape);
        outputTypes.add(tensor.type);
      });
    } catch (e) {
      print('Error while creating interpreter: $e');
    }
  }

  // input image에 대해서 192*192 tensorImage로 reformat합니다.
  @override
  TensorImage getProcessedImage(TensorImage inputImage) {
    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        .add(NormalizeOp(0, 255))
        .build();

    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  // image library의 Image class를 input으로 받습니다.
  // outputBuffer 초기화는 loadModel() 메소드에 있습니다.
  // outputLandmarks에는 x, y, z 축에 대해서 각각 468개의 점이 담깁니다. 총 1414개
  // outputScores에는 분석값에 대한 벤치마크 점수가 담깁니다. 음수이면 landmark를 사용할 수 없습니다.
  // 따라서 outputScores가 음수면 null을 리턴합니다.

  Map<String, dynamic>? predict(image_lib.Image image) {
    if (interpreter == null) {
      print('Interpreter not initialized');
      return null;
    }

    if (Platform.isAndroid) {
      image = image_lib.copyRotate(image, -90);
      image = image_lib.flipHorizontal(image);
    }
    final tensorImage = TensorImage(TfLiteType.float32);
    tensorImage.loadImage(image);
    final inputImage = getProcessedImage(tensorImage);

    TensorBuffer outputLandmarks = TensorBufferFloat(outputShapes[0]);
    TensorBuffer outputScores = TensorBufferFloat(outputShapes[1]);

    final inputs = <Object>[inputImage.buffer];

    final outputs = <int, Object>{
      0: outputLandmarks.buffer,
      1: outputScores.buffer,
    };

    interpreter!.runForMultipleInputs(inputs, outputs);
    print(outputScores.getDoubleValue(0));
    if (outputScores.getDoubleValue(0) < 0) {
      return null;
    }

    final landmarkPoints = outputLandmarks.getDoubleList().reshape([468, 3]);

    // [1,1,1,1414]

    final landmarkResults = <Offset>[];
    for (var point in landmarkPoints) {
      landmarkResults.add(Offset(
        point[0] / inputSize * image.width,
        point[1] / inputSize * image.height,
      ));
    }

    return {'point': landmarkResults};
  }
}

// compute, isolate와 같은 백그라운드 실행을 위해서 전역 메소드로 선언합니다.
// 아직 공부 중이기에 추후 수정될 수 있습니다.
Map<String, dynamic>? runFaceMesh(Map<String, dynamic> params) {
  final faceMesh =
  FaceMesh(interpreter: Interpreter.fromAddress(params['detectorAddress']));
  final image = ImageUtils.convertCameraImage(params['cameraImage']);
  final result = faceMesh.predict(image!);

  return result;
}

