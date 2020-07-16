import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:mubs_background_location/mubs_background_location.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum Status { UNKNOWN, RUNNING, STOPPED }

class _MyAppState extends State<MyApp> {
  ReceivePort port = ReceivePort();

  String logStr = '';
  LocationDto lastLocation;
  DateTime lastTimeLocation;
  LocationManager locationManager = LocationManager.instance;
  Stream<LocationDto> stream;
  StreamSubscription<LocationDto> subscription;
  Status _status = Status.UNKNOWN;

  @override
  void initState() {
    super.initState();
    stream = locationManager.dtoStream;
    subscription = stream.listen(onData);
  }

  void onData(LocationDto dto) {
    print('DTO: ${dto}');
    setState(() {
      if (_status == Status.UNKNOWN) {
        _status = Status.RUNNING;
      }
      lastLocation = dto;
      lastTimeLocation = DateTime.now();
    });
  }

  void start() async {
    if (subscription != null) {
      subscription.cancel();
    }
    subscription = stream.listen(onData);
    await locationManager.start();
    setState(() {
      _status = Status.RUNNING;
    });
  }

  void stop() async {
    subscription.cancel();
    await locationManager.stop();
    setState(() {
      _status = Status.STOPPED;
    });
  }

  Widget button() {
    Function f = start;
    String msg = 'START';
    if (_status == Status.RUNNING) {
      f = stop;
      msg = 'STOP';
    }
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

  String locationStr(LocationDto dto) =>
      '${lastLocation.latitude}, ${lastLocation.longitude} @ ${DateTime.fromMillisecondsSinceEpoch(lastLocation.time ~/ 1)}';

  Widget lastLoc() {
    return Text(lastLocation != null
        ? locationStr(lastLocation)
        : 'Unknown last location');
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
          title: const Text('MUBS Background Location'),
        ),
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[button(), status(), lastLoc()],
            ),
          ),
        ),
      ),
    );
  }
}
