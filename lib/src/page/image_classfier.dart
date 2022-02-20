import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:logger/logger.dart';

import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import '../model/face_mesh.dart';
import '../model/face_mesh_painter.dart';

class ImageClassifierExample extends StatefulWidget {
  const ImageClassifierExample({Key? key}) : super(key: key);

  @override
  _ImageClassifierExampleState createState() => _ImageClassifierExampleState();
}

class _ImageClassifierExampleState extends State<ImageClassifierExample> {
  final FaceMesh _faceMesh = FaceMesh(numThreads: 1);

  Map<String, dynamic>? results = <String, dynamic>{};
  var logger = Logger();

  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;

  Category? category;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!, width: 192, height: 192,);

      _predict();
    });
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    results = _faceMesh.predict(imageInput);
    print(results);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double _ratio = screenSize.width / screenSize.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('TfLite Flutter Helper',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: [
              Center(
                child: _image == null
                    ? Text('No image selected.')
                    : Container(
                        constraints: BoxConstraints(maxHeight: 192),
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: _imageWidget,
                      ),
              ),
              Center(
                  child: CustomPaint(
                painter: FaceMeshPainter(
                  points: results?['point'] ?? [],
                  ratio: _ratio,
                ),
              ))
            ],
          ),
          SizedBox(
            height: 36,
          ),
          Text(
            category != null ? category!.label : '',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            category != null
                ? 'Confidence: ${category!.score.toStringAsFixed(3)}'
                : '',
            style: TextStyle(fontSize: 16),
          ),
          OutlinedButton(onPressed: _predict, child: Text("test"))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
