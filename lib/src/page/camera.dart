import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:practice1/src/utils/image_utils.dart';

import '../../main.dart';
import '../model/face_mesh.dart';
import '../model/face_mesh_painter.dart';

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);

  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  CameraController controller =
      CameraController(cameras[0], ResolutionPreset.max);
  final FaceMesh _faceMesh = FaceMesh(numThreads: 1);

  late final double _ratio;
  Map<String, dynamic>? results = <String, dynamic>{};
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) {
        // image 값이 계속 변화하면서 UI를 변경
        if (!isDetecting) {
          isDetecting = true;

          // CameraImage => Image
          // image => tensorflow 모델의 input type으로 변환하는 코드 필요
          _predict(ImageUtils.convertCameraImage(image)!);
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
    results = _faceMesh.predict(imageInput);
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    _ratio = screenSize.width / controller.value.previewSize!.height;

    return MaterialApp(
        home: Stack(
      children: [
        CameraPreview(controller),
        CustomPaint(
          painter: FaceMeshPainter(
            points: results?['point'] ?? [],
            ratio: _ratio,
          ),
        )
      ],
    ));
  }
}
