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
  String address = 'unknown', name = 'unknown', log = 'Movisens event log:\n';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  /// Set up movisens data stream
  Future<void> initPlatformState() async {
    MovisensFlutter movisens = new MovisensFlutter();

    int weight = 100, height = 180, age = 25;

    setState(() {
      address = '88:6B:0F:82:1D:33';
      name = 'Sensor 02655';
    });

    UserData userData = new UserData(
        weight, height, Gender.male, age, SensorLocation.chest, address, name);

    movisens.startSensing(userData);
    movisens.movisensStream.listen(onData);
  }

  void onData(MovisensDataPoint dataPoint) {
    setState(() {
      log += '\t$dataPoint\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Movisens Plugin'),
        ),
        body: new Center(
          child: new Text('Running on Device: $name ($address)\n\n$log'),
        ),
      ),
    );
  }
}
