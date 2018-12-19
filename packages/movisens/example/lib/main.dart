import 'package:flutter/material.dart';
import 'dart:async';


import 'package:flutter/services.dart';
import 'package:movisens_flutter/movisens_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }
  /// Set up movisens data stream
  Future<void> initPlatformState() async {
   MovisensFlutter movisens = new MovisensFlutter();
   movisens.startSensing();
   movisens.movisensStream.listen(onData);

  }

  void onData(MovisensDataPoint data) {
    print('FLUTTER: $data');

  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
