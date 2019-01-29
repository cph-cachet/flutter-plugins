import 'package:flutter/material.dart';
import 'package:movisens_flutter/movisens_flutter.dart';

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
  int value = 2;
  String address = 'unknown', name = 'unknown';
  Movisens movisens = new Movisens();
  List<String> log = [];

  @override
  void initState() {
    super.initState();
    int weight = 100, height = 180, age = 25;

    setState(() {
      address = '88:6B:0F:82:1D:33';
      name = 'Sensor 02655';
    });

    UserData userData = new UserData(
        weight, height, Gender.male, age, SensorLocation.chest, address, name);

    movisens.startSensing(userData);
    movisens.movisensStream.listen(onData);
  }

  void onData(MovisensDataPoint d) {
    setState(() {
      log.add('$d');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movisens Log App',
      theme: darkTheme,
      home: Scaffold(
        body: ListView.builder(
            itemCount: this.log.length,
            itemBuilder: (context, index) => this._buildRow(index)),
      ),
    );
  }

  _buildRow(int index) {
    return new Container(
        child: new ListTile(title: new Text(log[index])),
        decoration:
            new BoxDecoration(border: new Border(bottom: new BorderSide())));
  }
}
