import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:weather/weather.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _res = 'Unknown';
  String key = '12b6e28582eb9298577c734a31ba9f4f';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    queryForecast();
  }

  void queryForecast() async {
    Weather w = new Weather(key);
    String res = await w.getCurrentWeather();
    setState(() {
      _res = res;
    });
  }

  void queryWeather() async {
    Weather w = new Weather(key);
    String res = await w.getFiveDayForecast();
    setState(() {
      _res = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Noise Level Example"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_res,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: queryForecast,
            child: Icon(Icons.cloud_download)
        ),
      ),
    );
  }

}
