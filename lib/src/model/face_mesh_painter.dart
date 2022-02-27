import 'dart:ui';

import 'package:flutter/material.dart';

// FaceMesh landmark를 그려주는 class 입니다.
// 출처 : https://github.com/JaeHeee/FlutterWithMediaPipe/
// points와 ratio를 받아서 비율에 맞게 점을 그려줍니다.
class FaceMeshPainter extends CustomPainter {
  final List<Offset> points;
  final double ratio;

  FaceMeshPainter({
    required this.points,
    required this.ratio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isNotEmpty) {
      var paint1 = Paint()
        ..color = Colors.amber
        ..strokeWidth = 4;

      canvas.drawPoints(PointMode.points,
          points.map((point) => point * ratio).toList(), paint1);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}