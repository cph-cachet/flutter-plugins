import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carp_background_location/carp_background_location.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum LocationStatus { UNKNOWN, RUNNING, STOPPED }

String dtoToString(LocationDto dto) =>
    'Location ${dto.latitude}, ${dto.longitude} at ${DateTime.fromMillisecondsSinceEpoch(dto.time ~/ 1)}';

Widget dtoWidget(LocationDto dto) {
  if (dto == null)
    return Text("No location yet");
  else
    return Column(
      children: <Widget>[
        Text(
          '${dto.latitude}, ${dto.longitude}',
        ),
        Text(
          '@',
        ),
        Text('${DateTime.fromMillisecondsSinceEpoch(dto.time ~/ 1)}')
      ],
    );
}

class _MyAppState extends State<MyApp> {
  String logStr = '';
  LocationDto lastLocation;
  DateTime lastTimeLocation;
  Stream<LocationDto> locationStream;
  StreamSubscription<LocationDto> locationSubscription;
  LocationStatus _status = LocationStatus.UNKNOWN;

  @override
  void initState() {
    super.initState();

    // Subscribe to stream in case it is already running
    LocationManager().interval = 1;
    LocationManager().distanceFilter = 0;
    LocationManager().notificationTitle = 'CARP Location Example';
    LocationManager().notificationMsg = 'CARP is tracking your location';
    locationStream = LocationManager().locationStream;
    locationSubscription = locationStream.listen(onData);
  }

  void onGetCurrentLocation() async {
    LocationDto dto = await LocationManager().getCurrentLocation();
    print('Current location: $dto');
  }

  void onData(LocationDto dto) {
    print(dtoToString(dto));
    setState(() {
      if (_status == LocationStatus.UNKNOWN) {
        _status = LocationStatus.RUNNING;
      }
      lastLocation = dto;
      lastTimeLocation = DateTime.now();
    });
  }

  void start() async {
    // Subscribe if it hasn't been done already
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    locationSubscription = locationStream.listen(onData);
    await LocationManager().start();
    setState(() {
      _status = LocationStatus.RUNNING;
    });
  }

  void stop() async {
    setState(() {
      _status = LocationStatus.STOPPED;
    });
    locationSubscription.cancel();
    await LocationManager().stop();
  }

  Widget stopButton() {
    Function f = stop;
    String msg = 'STOP';

    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        child: Text(msg),
        onPressed: f,
      ),
    );
  }

  Widget startButton() {
    Function f = start;
    String msg = 'START';
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        child: Text(msg),
        onPressed: f,
      ),
    );
  }

  Widget status() {
    String msg = _status.toString().split('.').last;
    return Text("Status: $msg");
  }

  Widget lastLoc() {
    return Text(
        lastLocation != null
            ? dtoToString(lastLocation)
            : 'Unknown last location',
        textAlign: TextAlign.center);
  }

  Widget getButton() {
    return RaisedButton(
      child: Text("Get Current Location"),
      onPressed: onGetCurrentLocation,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

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
                Divider(),
                status(),
                Divider(),
                dtoWidget(lastLocation),
                getButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
