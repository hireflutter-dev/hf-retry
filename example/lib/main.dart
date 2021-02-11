import 'package:flutter/material.dart';
import 'package:hr_retry/hr_retry.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Center(
          child: Image(
            image: NetworkImageWithRetry(
              'https://miro.medium.com/max/1000/1*ilC2Aqp5sZd1wi0CopD1Hw.png',
            ),
          ),
        ),
      ),
    );
  }
}
