import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movisens_flutter/movisens_flutter.dart';
import 'file_io.dart';

ThemeData darkTheme = ThemeData(
  // Define the default Brightness and Colors
  brightness: Brightness.dark,
  primaryColor: Colors.lightBlue[800],
  accentColor: Colors.cyan[600],

  // Define the default Font Family
  fontFamily: 'Montserrat',

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  ),
);

void main() => runApp(MovisensApp());

class MovisensApp extends StatefulWidget {
  @override
  _MovisensAppState createState() => _MovisensAppState();
}

class _MovisensAppState extends State<MovisensApp> {
  Movisens _movisens;
  StreamSubscription<MovisensDataPoint> _subscription;
  LogManager logManager = new LogManager();
  List<MovisensDataPoint> movisensEvents = [];
  String address = 'unknown', name = 'unknown';
  int weight, height, age;

  @override
  void initState() {
    super.initState();
    startListening();
  }

  void onData(MovisensDataPoint d) {
    setState(() {
      movisensEvents.add(d);
      logManager.writeLog('$d');
    });
  }

  void stopListening() {
    _subscription.cancel();
  }

  void startListening() {
    address = '88:6B:0F:82:1D:33';
    name = 'Sensor 02655';
    weight = 100;
    height = 180;
    age = 25;

    UserData userData = new UserData(
        weight, height, Gender.male, age, SensorLocation.chest, address, name);

    _movisens = new Movisens(userData);

    try {
      _subscription = _movisens.movisensStream.listen(onData);
    } on MovisensException catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movisens Log App',
      theme: darkTheme,
      home: Scaffold(
        body: ListView.builder(
            itemCount: this.movisensEvents.length,
            itemBuilder: (context, index) => this._buildRow(index)),
      ),
    );
  }

  _buildRow(int index) {
    MovisensDataPoint d = movisensEvents[index];
    return new Container(
        child: new ListTile(
          leading: Icon(_getIcon(d)),
          title: new Text(
            d.toString(),
            style: TextStyle(fontSize: 12),
          ),
        ),
        decoration:
            new BoxDecoration(border: new Border(bottom: new BorderSide())));
  }

  IconData _getIcon(MovisensDataPoint d) {
    if (d is MovisensTapMarker) return Icons.touch_app;
    if (d is MovisensMovementAcceleration) return Icons.arrow_downward;
    if (d is MovisensBodyPosition) return Icons.accessibility;
    if (d is MovisensMet) return Icons.cached;
    if (d is MovisensStepCount) return Icons.directions_walk;
    if (d is MovisensBatteryLevel) return Icons.battery_charging_full;
    if (d is MovisensStatus)
      return Icons.bluetooth_connected;
    else
      return Icons.device_unknown;
  }
}
