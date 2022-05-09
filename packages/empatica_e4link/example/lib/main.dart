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
  String _bvp = '';
  String _gsr = '';
  String _ibi = '';
  String _battery = '';
  String _temperature = '';
  int? _x;
  int? _y;
  int? _z;
  String _tag = '';
  String _sensorStatus = '';
  int? _onWristStatusStatus;

  @override
  void initState() {
    super.initState();
    _connectToAPI();
  }

  Future<void> _connectToAPI() async {
    deviceManager.eventSink?.listen((event) async {
      print(event);
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
            case 'DISCONNECTED':
              await deviceManager.startScanning();
              break;
            default:
          }
          break;
        case 'DiscoverDevice':
          await deviceManager.connectDevice(event['device']);
          break;
        case 'ReceiveBVP':
          setState(() {
            _bvp = event['bvp'].toString();
          });
          break;
        case 'ReceieveIBI':
          setState(() {
            _ibi = event['ibi'].toString();
          });
          break;
        case 'ReceiveGSR':
          setState(() {
            _gsr = event['gsr'].toString();
          });
          break;
        case 'ReceiveBatteryLevel':
          setState(() {
            _battery = event['batteryLevel'].toString();
          });
          break;
        case 'ReceiveTemperature':
          setState(() {
            _temperature = event['temperature'].toString();
          });
          break;
        case 'ReceiveTag':
          setState(() {
            _tag = event['timestamp'].toString();
          });
          break;
        case 'ReceiveAcceleration':
          setState(() {
            _x = event['x'];
            _y = event['y'];
            _z = event['z'];
          });
          break;
        case 'UpdateSensorStatus':
          setState(() {
            _sensorStatus = event['sensorStatus'];
          });
          break;
        case 'UpdateOnWristStatus':
          setState(() {
            _onWristStatusStatus = event['status'];
          });
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
          title: const Text('Empatica example app'),
        ),
        body: Center(
          child: Text(
              'Status: $_status\nBVP: $_bvp\nGSR: $_gsr\nIBI: $_ibi\nBattery: $_battery\nTemperature: $_temperature\nX: $_x\nY: $_y\nZ: $_z\nTag: $_tag\nSensorStatus: $_sensorStatus\nOnWristStatus: $_onWristStatusStatus'),
        ),
      ),
    );
  }
}
