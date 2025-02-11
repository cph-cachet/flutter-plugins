import 'package:flutter/material.dart';
import 'dart:async';
import 'package:light/light.dart';

void main() => runApp(LightApp());

class LightApp extends StatefulWidget {
  @override
  LightAppState createState() => LightAppState();
}

class LightAppState extends State<LightApp> {
  String _luxString = 'Unknown';
  StreamSubscription<int>? _lightEvents;

  void startListening() {
    try {
      _lightEvents =
          Light().lightSensorStream.listen((luxValue) => setState(() {
                _luxString = "$luxValue";
              }));
    } catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _lightEvents?.cancel();
  }

  @override
  void initState() {
    super.initState();
    startListening();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: const Text('Light Example App')),
      body: Center(child: Text('Lux value: $_luxString\n')),
    ));
  }
}
