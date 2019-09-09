import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceName = 'Unknown';
  int _voltage = -1;
  bool _deviceConnecting, _deviceConnected;
  bool sampling = false;
  String _event;

  // the name of the eSense device to connect to -- change this to your own device.
  String eSenseName = 'eSense-0332';

  @override
  void initState() {
    super.initState();
    setupESense();
  }

  Future<void> setupESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      setState(() {
        _deviceConnected = ESenseManager.connected;
      });
    });

    con = await ESenseManager.connect(eSenseName);

    print('con : $con');

    setState(() {
      _deviceConnecting = con;
    });
  }

  void _getESenseInfo() async {
    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName;
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage;
            break;
        }
      });
    });

    print('getDeviceName: ${await ESenseManager.getDeviceName()}');
    print('getBatteryVoltage: ${await ESenseManager.getBatteryVoltage()}');

    ESenseManager.getDeviceName();
    ESenseManager.getBatteryVoltage();
    ESenseManager.getAccelerometerOffset();
    ESenseManager.getAdvertisementAndConnectionInterval();
    ESenseManager.getSensorConfig();
  }

  StreamSubscription subscription;
  void _startListenToSensor() async {
    subscription = ESenseManager.sensorEvents.listen((event) {
      print('SENSOR event: $event');
      setState(() {
        sampling = true;
        _event = event.toString();
      });
    });
    setState(() {
      sampling = true;
    });
  }

  void _stopListenToSensor() async {
    subscription.cancel();
    setState(() {
      sampling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('eSense Demo App'),
        ),
        body: Align(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Text('eSense Device Connecting: $_deviceConnecting'),
              Text('eSense Device Connected: $_deviceConnected'),
              Text('eSense Device Name: $_deviceName'),
              Text('eSense Battery Level: $_voltage'),
              Text('$_event'),
            ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          // a floating button that starts/stops listening to sensor events.
          // is disabled until we're connected to the device.
          onPressed: (!ESenseManager.connected) ? null : (!sampling) ? _startListenToSensor : _stopListenToSensor,
          tooltip: 'Listen to eSense sensors',
          child: (!sampling) ? Icon(Icons.play_arrow) : Icon(Icons.stop),
        ),
      ),
    );
  }
}
