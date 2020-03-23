/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:weather/weather.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _res = 'Unknown';
  String key = '12b6e28582eb9298577c734a31ba9f4f';
  WeatherStation ws;
  String _errMessage;

  @override
  void initState() {
    super.initState();
    ws = new WeatherStation(key);
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    queryWeather();
  }

  void queryForecast() async {
    List<Weather> f = await ws.fiveDayForecast();
    setState(() {
      _errMessage = null;
      _res = f.toString();
    });
  }

  void queryWeather() async {
    Weather w = await ws.currentWeather();
    setState(() {
      _errMessage = null;
      _res = w.toString();
    });
  }

  void resetLocation() {
    ws.locationData = null;
    queryWeather();
  }

  void setLocation() {
    ws.locationData = LocationData.fromMap({
      'latitude': 48.573509,
      'longitude': 13.463970,
    });
    queryWeather();
  }

  void getLocationByQuery(String q) async {
    ws.currentWeather(q: q).then((Weather w) {
      setState(() {
        _errMessage = null;
        _res = w.toString();
      });
    }).catchError((err) {
      setState(() {
        _errMessage = err.response['message'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Weather API Example"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  maxLines: 1,
                  onSubmitted: (String input) {
                    getLocationByQuery(input);
                  },
                  decoration: InputDecoration(
                    errorText: _errMessage,
                    helperText: "Search for a City",
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
              ),
              Text(
                _res,
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: setLocation,
              child: Icon(Icons.location_on),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            FloatingActionButton(
              onPressed: resetLocation,
              child: Icon(Icons.cloud_download),
            ),
          ],
        ),
      ),
    );
  }
}
