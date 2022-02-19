import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'package:practice1/src/model/classifier.dart';

class ClassifierFaceMesh extends Classifier {
  ClassifierFaceMesh({int numThreads: 1}) : super(numThreads: numThreads);

  @override
  String get modelName => 'models/face_landmark.tflite';
  // @override
  // String get modelName => 'models/mobilenet_v1_1.0_224_quant.tflite';



  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(0, 1);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 255);
}