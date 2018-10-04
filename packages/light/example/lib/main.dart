import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_light/flutter_light.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _luxString = 'Unknown';

  StreamSubscription<int> _subscription;
  Light _light;

  void _onData(int luxValue) async {
    setState(() {
      _luxString = "$luxValue";
    });
  }

  void _onDone() {

  }

  void _onError(error) {
    // Handle the error
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _light = new Light();
    _subscription = _light.lightSensorStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Running on: $_luxString\n'),
        ),
      ),
    );
  }
}
