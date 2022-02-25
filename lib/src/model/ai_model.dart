import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

// ignore: must_be_immutable
// ai model을 구현할 때, 필수적으로 구현해야하는 것들을 적어놓은 추상 클래스입니다.
// 출처 : https://github.com/JaeHeee/FlutterWithMediaPipe/
abstract class AiModel extends Equatable {
  AiModel({this.interpreter});

  final outputShapes = <List<int>>[];
  final outputTypes = <TfLiteType>[];

  Interpreter? interpreter;

  @override
  List<Object> get props => [];

  int get getAddress;

  Future<void> loadModel();
  TensorImage getProcessedImage(TensorImage inputImage);
  // FutureOr<dynamic>? predict(image_lib.Image image);
}