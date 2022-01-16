import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _show,
      child: Scaffold(
          body: Container(
            child: Stack(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 400,
                  width: 400,
                  color: Colors.amber,
                  child: Text("Hello world"),
                ),
                Positioned(
                    top: 25,
                    bottom: 25,
                    left: 50,
                    right: 50,
                    child: Container(
                      height: 200,
                      width: 200,
                      color: Colors.red,
                      child: Text("Hello world"),
                    )),
                Container(
                  height: 100,
                  width: 100,
                  color: Colors.blue,
                  child: Text("Hello world"),
                ),
              ],
            ),
          )),
    );
  }
}