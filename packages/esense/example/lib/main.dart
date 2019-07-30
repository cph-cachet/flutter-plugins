import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:esense/esense.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _deviceName = 'Unknown';
  int _voltage = 0;
  bool _deviceConnected;
  String eSenseName = 'eSense-0332';

  @override
  void initState() {
    super.initState();
    getPlatformVersion();
    setupESense();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getPlatformVersion() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PlatformVersion.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> setupESense() async {
    bool con = false, nam = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) => print('CONNECTION event: $event'));
    con = await ESenseManager.connect(eSenseName);

    ESenseManager.eSenseEvents.listen((event) => print('ESENSE #1 event: $event'));

    setState(() {
      _deviceConnected = con;
    });

    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE #2 event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).name;
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage;
            break;
        }
      });
    });
  }

  void _getESenseInfo() async {
    print('getDeviceName: ${await ESenseManager.getDeviceName()}');
    print('getBatteryVoltage: ${await ESenseManager.getBatteryVoltage()}');

    setState(() {
      _deviceConnected = ESenseManager.connected;
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
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('eSense Device Connected: $_deviceConnected'),
              Text('eSense Device Name: $_deviceName'),
              Text('eSense Battery Level: $_voltage'),
            ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: _getESenseInfo,
          tooltip: 'Get eSense Device Info',
          child: new Icon(Icons.add),
        ),
      ),
    );
  }
}
