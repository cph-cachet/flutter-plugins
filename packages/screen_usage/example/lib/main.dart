import 'package:flutter/material.dart';
import 'dart:async';
import 'package:screen_usage/screen_usage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Screen _screen = new Screen();
  StreamSubscription<ScreenEvent> _subscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    _subscription = _screen.screenEvents.listen(_onData, onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  void _onData(ScreenEvent event) async {
    print(event);
  }

  void _onDone() {}

  void _onError(error) {
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Screen Usage App'),
        ),
        body: new Center(),
      ),
    );
  }
}
