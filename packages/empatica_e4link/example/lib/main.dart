import 'package:flutter/material.dart';
import 'dart:async';

import 'package:empatica_e4link/empatica.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  EmpaticaPlugin deviceManager = EmpaticaPlugin();

  String _status = 'INITIAL';

  @override
  void initState() {
    super.initState();
    _connectToAPI();
  }

  Future<void> _connectToAPI() async {
    deviceManager.statusEvents?.listen((event) {
      print(event);
      if (event.containsKey('status')) {
        setState(() {
          _status = event['status'];
        });
      }
    });

    if (_status == 'INITIAL') {
      await deviceManager
          .authenticateWithAPIKey('apiKeyGoesHere');
    }
    if (_status == 'READY') {
      await deviceManager.startScanning();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Status: $_status\n'),
        ),
      ),
    );
  }
}
