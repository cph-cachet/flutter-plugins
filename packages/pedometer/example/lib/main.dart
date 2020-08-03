import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<StepCount> _stepCountStream;
  StepCount _stepCount;

  Stream<PedestrianStatus> _stepDetectionStream;
  PedestrianStatus _pedestrianStatus;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    event.steps;
    event.timeStamp;
    print(event);
    setState(() {
      _stepCount = event;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    event.status;
    event.timeStamp;
    print(event);
    setState(() {
      _pedestrianStatus = event;
    });
  }

  Future<void> initPlatformState() async {
    _stepDetectionStream = await Pedometer.pedestrianStatusStream;
    _stepDetectionStream.listen(onPedestrianStatusChanged);

    _stepCountStream = await Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount);

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Steps taken:',
                style: TextStyle(fontSize: 30),
              ),

              Text(
                '${_stepCount != null ? _stepCount.steps : '?'}',
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              Text(
                'Pedestrian status:',
                style: TextStyle(fontSize: 30),
              ),
              Icon(
                _pedestrianStatus != null
                    ? _pedestrianStatus.status == 'walking'
                        ? Icons.directions_walk
                        : Icons.accessibility_new
                    : Icons.device_unknown,
                size: 100,
              ),
              Text(
                '(${_pedestrianStatus != null ? _pedestrianStatus.status : '?'})',
                style: TextStyle(fontSize: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
