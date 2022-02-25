import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice1/src/page/camera.dart';
import 'package:practice1/src/page/image_classfier.dart';

import 'package:practice1/src/provider/firebase_auth.dart';
import 'package:practice1/src/provider/firebase_firestore.dart';

import 'package:provider/provider.dart';

import './page/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("firebase load fail $snapshot"),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
                Provider(create: (_) => FirebaseFirestoreProvider()),
              ],
              child: MaterialApp(
                title: 'Flutter Demo',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                // home: CameraExample(),
                home: CameraExample(),
              ));
        }
        return CircularProgressIndicator();
      },
    );
  }
}
