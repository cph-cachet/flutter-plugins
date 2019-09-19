import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Pedometer _pedometer;
  StreamSubscription<int> _subscription;
  String _stepCountValue = 'unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    startListening();
  }

  void onData(int stepCountValue) {
    print(stepCountValue);
  }

  void startListening() {
    _pedometer = new Pedometer();
    _subscription = _pedometer.stepCountStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  void stopListening() {
    _subscription.cancel();
  }

  void _onData(int stepCountValue) async {
    setState(() => _stepCountValue = "$stepCountValue");
  }

  void _onDone() => print("Finished pedometer tracking");

  void _onError(error) => print("Flutter Pedometer Error: $error");


  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Pedometer example app'),
        ),
        body: new Text('Step count: $_stepCountValue')
      ),
    );
  }
}
