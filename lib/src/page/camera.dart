import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import '../../main.dart';
import '../model/classifier.dart';
import '../model/classifier_face_mesh.dart';

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);

  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  late CameraController controller;
  late CameraImage cameraImage;
  late Classifier _classifier;

  bool isDetecting = false;
  var output;

  @override
  void initState() {
    super.initState();
    _classifier = ClassifierFaceMesh();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) {
        if (!isDetecting) {
          isDetecting = true;
          cameraImage = image;

          // image => tensorflow 모델의 input type으로 변환하는 코드 필요
          _predict(imglib.grayscale(convertYUV420(image)));
        }
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _predict(imglib.Image imageInput) async {
    var pred = _classifier.predict(imageInput);
  }

  imglib.Image convertYUV420(CameraImage image) {
    var img = imglib.Image(image.width, image.height); // Create Image buffer

    Plane plane = image.planes[0];
    const int shift = (0xFF << 24);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
          planeOffset < image.height * image.width;
          planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        // Calculate pixel color
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        img.data[planeOffset + x] = newVal;
      }
    }

    print(img);
    return img;
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
