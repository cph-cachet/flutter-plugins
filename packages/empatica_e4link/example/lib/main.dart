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
    deviceManager.statusEvents?.listen((event) async {
      switch (event['type']) {
        case 'Listen':
          await deviceManager
              .authenticateWithAPIKey('apiKeyGoesHere');
          break;
        case 'UpdateStatus':
          setState(() {
            _status = event['status'];
          });
          switch (event['status']) {
            case 'READY':
              await deviceManager.startScanning();
              break;
            case 'DISCONNECTED':
              await deviceManager.startScanning();
              break;
            default:
          }

          break;
        case 'DiscoverDevice':
          await deviceManager.connectDevice(event['device']);
          break;
        default:
      }
    });
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
