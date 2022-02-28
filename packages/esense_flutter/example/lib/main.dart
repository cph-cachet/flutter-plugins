import 'package:flutter/material.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceName = 'Unknown';
  double _voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  String _button = 'not pressed';
  bool connected = false;

  // the name of the eSense device to connect to -- change this to your own device.
  String eSenseName = 'eSense-0164';

  @override
  void initState() {
    super.initState();
    _listenToESense();
  }

  Future<void> _askForPermissions() async {
    if (!(await Permission.bluetooth.request().isGranted)) {
      print(
          'WARNING - no permission to use Bluetooth granted. Cannot access eSense device.');
    }
    if (!(await Permission.locationWhenInUse.request().isGranted)) {
      print(
          'WARNING - no permission to access location granted. Cannot access eSense device.');
    }
  }

  Future<void> _listenToESense() async {
    await _askForPermissions();
    // if you want to get the connection events when connecting,
    // set up the listener BEFORE connecting...
    ESenseManager().connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) _listenToESenseEvents();

      setState(() {
        connected = false;
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            connected = true;
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });
  }

  Future<void> _connectToESense() async {
    print('connecting... connected: $connected');
    if (!connected) connected = await ESenseManager().connect(eSenseName);

    setState(() {
      _deviceStatus = connected ? 'connecting' : 'connection failed';
    });
  }

  void _listenToESenseEvents() async {
    ESenseManager().eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName ?? 'Unknown';
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage ?? -1;
            break;
          case ButtonEventChanged:
            _button = (event as ButtonEventChanged).pressed
                ? 'pressed'
                : 'not pressed';
            break;
          case AccelerometerOffsetRead:
            // TODO
            break;
          case AdvertisementAndConnectionIntervalRead:
            // TODO
            break;
          case SensorConfigRead:
            // TODO
            break;
        }
      });
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(
      const Duration(seconds: 10),
      (timer) async =>
          (connected) ? await ESenseManager().getBatteryVoltage() : null,
    );

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(const Duration(seconds: 2),
        () async => await ESenseManager().getDeviceName());
    Timer(const Duration(seconds: 3),
        () async => await ESenseManager().getAccelerometerOffset());
    Timer(
        const Duration(seconds: 4),
        () async =>
            await ESenseManager().getAdvertisementAndConnectionInterval());
    Timer(const Duration(seconds: 5),
        () async => await ESenseManager().getSensorConfig());
  }

  StreamSubscription? subscription;
  void _startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager().sensorEvents.listen((event) {
      print('SENSOR event: $event');
      setState(() {
        _event = event.toString();
      });
    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    subscription?.cancel();
    setState(() {
      sampling = false;
    });
  }

  @override
  void dispose() {
    _pauseListenToSensorEvents();
    ESenseManager().disconnect();
    super.dispose();
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
          child: ListView(
            children: [
              Text('eSense Device Status: \t$_deviceStatus'),
              Text('eSense Device Name: \t$_deviceName'),
              Text('eSense Battery Level: \t$_voltage'),
              Text('eSense Button Event: \t$_button'),
              const Text(''),
              Text(_event),
              Container(
                height: 80,
                width: 200,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: TextButton.icon(
                  onPressed: _connectToESense,
                  icon: const Icon(Icons.login),
                  label: const Text(
                    'CONNECT....',
                    style: TextStyle(fontSize: 35),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          // a floating button that starts/stops listening to sensor events.
          // is disabled until we're connected to the device.
          onPressed: (!ESenseManager().connected)
              ? null
              : (!sampling)
                  ? _startListenToSensorEvents
                  : _pauseListenToSensorEvents,
          tooltip: 'Listen to eSense sensors',
          child: (!sampling)
              ? const Icon(Icons.play_arrow)
              : const Icon(Icons.pause),
        ),
      ),
    );
  }
}
