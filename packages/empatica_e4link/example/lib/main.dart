import 'package:flutter/material.dart';
import 'dart:io';

import 'package:empatica_e4link/empatica.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_background/flutter_background.dart';

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

  String _bvp = '';
  String _gsr = '';
  String _ibi = '';
  String _battery = '';
  String _temperature = '';
  int? _x;
  int? _y;
  int? _z;
  String _tag = '';
  int _sensorStatus = -1;
  int? _onWristStatus;

  @override
  Future<void> initState() async {
    super.initState();
    Permission.locationWhenInUse.request();

    _listenToStatus();
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "flutter_background example app",
      notificationText:
          "Background notification for keeping the example app running in the background",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    bool success =
        await FlutterBackground.initialize(androidConfig: androidConfig);
  }

  void _listenToStatus() {
    deviceManager.statusEventSink?.listen((event) async {
      switch (event.runtimeType) {
        case Listen:

          // if we are now listening to the status event sink
          // connect to the api
          // also could use authenticate with connect
          await deviceManager
              .authenticateWithAPIKey('apiKeyGoesHere');
          break;
        case UpdateStatus:

          //the status of the device manager
          switch ((event as UpdateStatus).status) {
            case EmpaStatus.connected:
              // when it's connected to the device
              // start streaming data
              _listenToData();
              break;
            default:
              setState(() {
                deviceManager.status = event.status;
              });
          }
          break;
        case DiscoverDevice:
          await deviceManager.connectDevice((event as DiscoverDevice).device);
          break;
        case UpdateSensorStatus:
          setState(() {
            _sensorStatus = (event as UpdateSensorStatus).status;
          });
          break;
      }
    });
  }

  void _listenToData() {
    deviceManager.dataEventSink?.listen((event) {
      switch (event.runtimeType) {
        // update each data point with the appropriate data
        case ReceieveBVP:
          setState(() {
            _bvp = (event as ReceieveBVP).bvp.toString();
          });
          break;
        case ReceiveGSR:
          setState(() {
            _gsr = (event as ReceiveGSR).gsr.toString();
          });
          break;
        case ReceiveIBI:
          setState(() {
            _ibi = (event as ReceiveIBI).ibi.toString();
          });
          break;
        case ReceieveBatteryLevel:
          setState(() {
            _battery = (event as ReceieveBatteryLevel).batteryLevel.toString();
            writeBattery(event.batteryLevel);
            readBattery();
          });
          break;
        case ReceiveTemperature:
          setState(() {
            _temperature = (event as ReceiveTemperature).temperature.toString();
          });
          break;
        case ReceiveAcceleration:
          setState(() {
            (event as ReceiveAcceleration);
            _x = event.x;
            _y = event.y;
            _z = event.z;
          });
          break;
        case ReceiveTag:
          //just a timestamp as a double in unix time
          setState(() {
            _tag = (event as ReceiveTag).timestamp.toString();
          });
          break;
        case UpdateOnWristStatus:
          setState(() {
            _onWristStatus = (event as UpdateOnWristStatus).status;
          });
          break;
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
              'Status: ${deviceManager.status}\nBVP: $_bvp\nGSR: $_gsr\nIBI: $_ibi\nBattery: $_battery\nTemperature: $_temperature\nX: $_x\nY: $_y\nZ: $_z\nTag: $_tag\nSensorStatus: $_sensorStatus\nOnWristStatus: $_onWristStatus'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            deviceManager.status == EmpaStatus.connected
                ? deviceManager.disconnect()
                : deviceManager.startScanning();
          },
          tooltip: 'Connect and disconnect',
          child: const Icon(Icons.bluetooth),
        ),
      ),
    );
  }
}

//log the battery level for research

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localPhoneBatteryFile async {
  final path = await _localPath;
  return File('$path/phoneBattery.txt');
}

Future<File> get _localWatchBatteryFile async {
  final path = await _localPath;
  return File('$path/watchBattery.txt');
}

Future<void> writeBattery(double watchbattery) async {
  final phonefile = await _localPhoneBatteryFile;
  final watchfile = await _localWatchBatteryFile;

  final watchobj = {
    'battery': watchbattery,
    'time': DateTime.now().toString(),
  };

  final phoneobj = {
    'battery': await Battery().batteryLevel,
    'time': DateTime.now().toString(),
  };

  // Write the file
  var phonesink = phonefile.openWrite(mode: FileMode.append);
  var watchsink = watchfile.openWrite(mode: FileMode.append);
  phonesink.write(phoneobj);
  phonesink.close();
  watchsink.write(watchobj);
  watchsink.close();
}

Future<void> readBattery() async {
  try {
    final file = await _localPhoneBatteryFile;
    final watchfile = await _localWatchBatteryFile;

    // Read the file
    final contents = await file.readAsString();
    final watchcontents = await watchfile.readAsString();
    print('phone $contents');
    print('watch $watchcontents');
  } catch (e) {
    // If encountering an error, return ''
  }
}
