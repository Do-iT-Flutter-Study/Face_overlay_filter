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
  // FaceMesh 모델을 불러옵니다
  final FaceMesh _faceMesh = FaceMesh();

  // FaceMesh 모델 분석값을 담을 변수입니다.
  Map<String, dynamic>? results = <String, dynamic>{};

  // Log에 관한 변수입니다.
  var logger = Logger();

  // image 변수와 파일에서 이미지를 찾는 데 활용할 imagePicker
  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;

  // 이건 굳이 사용하지 않습니다. labeling에 관한 class인데, 우리 모델은 labeling에 관한 모델이 아닙니다.
  Category? category;

  // 갤러리에서 이미지를 불러옵니다. 이미지를 불러오면 바로 분석합니다.
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!, width: 192, height: 192,);

      _predict();
    });
  }

  // 불러온 이미지를 분석하는데, 입력값 타입이 image library의 Image class이기 때문에 img.Image 타입으로 변환해줍니다.
  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    // results = _faceMesh.predict(imageInput);
    print(results);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 이미지를 불러오고, 분석하여 landmark를 표시해줍니다.
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
            // 이 부분에서 image에 관한 UI를 짜시면 됩니다.
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
