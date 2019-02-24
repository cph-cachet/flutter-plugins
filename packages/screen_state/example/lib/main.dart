import 'package:flutter/material.dart';
import 'dart:async';
import 'package:screen_state/screen_state.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Screen screen = new Screen();
    screen.listen(onData);
  }

  onData(ScreenStateEvent event) {
    print(event);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Screen State Example app'),
        ),
        body: new Center(),
      ),
    );
  }
}
