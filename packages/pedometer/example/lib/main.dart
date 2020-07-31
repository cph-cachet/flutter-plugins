import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<StepCountEvent> _stepCountStream;
  Stream<StepDetectionEvent> _stepDetectionStream;
  StepDetectionEvent _detectedStep;
  StepCountEvent _stepCount;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCountEvent event) {
    print(event);
    setState(() {
      _stepCount = event;
    });
  }

  void onStepDetected(StepDetectionEvent event) {
    print(event);
    setState(() {
      _detectedStep = event;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
//    try {
//      _stepCountStream = await Pedometer.stepCountStream;
//      _stepCountStream.listen(onStepCount);
//    } catch (error) {
//      print(error);
//    }

    _stepDetectionStream = await Pedometer.stepDetectionStream;
    _stepDetectionStream.listen(onStepDetected);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text(
                  'Steps taken: ${_stepCount != null ? _stepCount.steps : '?'}'),
              Text(
                  'Step detected at ${_detectedStep != null ? _detectedStep.timeStamp : '?'}')
            ],
          ),
        ),
      ),
    );
  }
}
