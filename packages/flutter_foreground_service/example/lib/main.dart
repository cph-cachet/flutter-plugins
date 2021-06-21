import 'package:flutter/material.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';

void main() {
  runApp(MyApp());
  startForegroundService();
}

void startForegroundService() async {
  ForegroundService().start();
  debugPrint("Started service");
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Foreground Service Example'),
        ),
        body: Center(
            child: Text('Foreground service example, check notification bar')),
      ),
    );
  }

  @override
  void dispose() {
    ForegroundService().stop();
    super.dispose();
  }
}
