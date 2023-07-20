import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carp_background_location/carp_background_location.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum LocationStatus { UNKNOWN, INITIALIZED, RUNNING, STOPPED }

class _MyAppState extends State<MyApp> {
  String logStr = '';
  LocationDto? _lastLocation;
  StreamSubscription<LocationDto>? locationSubscription;
  LocationStatus _status = LocationStatus.UNKNOWN;

  @override
  void initState() {
    super.initState();

    LocationManager().interval = 1;
    LocationManager().distanceFilter = 0;
    LocationManager().notificationTitle = 'CARP Location Example';
    LocationManager().notificationMsg = 'CARP is tracking your location';

    _status = LocationStatus.INITIALIZED;
  }

  void getCurrentLocation() async =>
      onData(await LocationManager().getCurrentLocation());

  void onData(LocationDto location) {
    print('>> $location');
    setState(() {
      _lastLocation = location;
    });
  }

  /// Is "location always" permission granted?
  Future<bool> isLocationAlwaysGranted() async =>
      await Permission.locationAlways.isGranted;

  /// Tries to ask for "location always" permissions from the user.
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> askForLocationAlwaysPermission() async {
    bool granted = await Permission.locationAlways.isGranted;

    if (!granted) {
      granted =
          await Permission.locationAlways.request() == PermissionStatus.granted;
    }

    return granted;
  }

  /// Start listening to location events.
  void start() async {
    // ask for location permissions, if not already granted
    if (!await isLocationAlwaysGranted())
      await askForLocationAlwaysPermission();

    locationSubscription?.cancel();
    locationSubscription = LocationManager().locationStream.listen(onData);
    await LocationManager().start();
    setState(() {
      _status = LocationStatus.RUNNING;
    });
  }

  void stop() {
    locationSubscription?.cancel();
    LocationManager().stop();
    setState(() {
      _status = LocationStatus.STOPPED;
    });
  }

  Widget stopButton() => SizedBox(
        width: double.maxFinite,
        child: ElevatedButton(
          child: const Text('STOP'),
          onPressed: stop,
        ),
      );

  Widget startButton() => SizedBox(
        width: double.maxFinite,
        child: ElevatedButton(
          child: const Text('START'),
          onPressed: start,
        ),
      );

  Widget statusText() => Text("Status: ${_status.toString().split('.').last}");

  Widget currentLocationButton() => SizedBox(
        width: double.maxFinite,
        child: ElevatedButton(
          child: const Text('CURRENT LOCATION'),
          onPressed: getCurrentLocation,
        ),
      );

  Widget locationWidget() {
    if (_lastLocation == null)
      return Text("No location yet");
    else
      return Column(
        children: <Widget>[
          Text(
            '${_lastLocation!.latitude}, ${_lastLocation!.longitude}',
          ),
          Text(
            '@',
          ),
          Text(
              '${DateTime.fromMillisecondsSinceEpoch(_lastLocation!.time ~/ 1)}')
        ],
      );
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CARP Background Location'),
        ),
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                startButton(),
                stopButton(),
                currentLocationButton(),
                Divider(),
                statusText(),
                Divider(),
                locationWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
