import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:mubs_background_location/mubs_background_location.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum LocationStatus { UNKNOWN, RUNNING, STOPPED }

String dtoToString(LocationDto dto) =>
    '${dto.latitude}, ${dto.longitude} @ ${DateTime.fromMillisecondsSinceEpoch(dto.time ~/ 1)}';

class _MyAppState extends State<MyApp> {
  String logStr = '';
  LocationDto lastLocation;
  DateTime lastTimeLocation;
  LocationManager locationManager = LocationManager.instance;
  Stream<LocationDto> dtoStream;
  StreamSubscription<LocationDto> dtoSubscription;
  LocationStatus _status = LocationStatus.UNKNOWN;

  @override
  void initState() {
    super.initState();
    // Subscribe to stream in case it is already running
    dtoStream = locationManager.dtoStream;
    dtoSubscription = dtoStream.listen(onData);
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

    // Subscribe if it hasnt been done already
    if (dtoSubscription != null) {
      dtoSubscription.cancel();
    }
    dtoSubscription = dtoStream.listen(onData);
    await locationManager.start();
    setState(() {
      _status = LocationStatus.RUNNING;
    });
  }

  void stop() async {
    setState(() {
      _status = LocationStatus.STOPPED;
    });
    dtoSubscription.cancel();
    await locationManager.stop();

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
    return Text(lastLocation != null
        ? dtoToString(lastLocation)
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
              children: <Widget>[
                startButton(),
                stopButton(),
                status(),
                lastLoc()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
