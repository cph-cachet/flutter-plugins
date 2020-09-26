import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_state/screen_state.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Screen _screen = Screen();
  StreamSubscription<ScreenStateEvent> _subscription;
  bool started = false;

  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    startListening();
  }

  void onData(ScreenStateEvent event) {
    print(event);
  }

  void startListening() {
    try {
      _subscription = _screen.screenStateStream.listen(onData);
      setState(() => started = true);
    } on ScreenStateException catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _subscription.cancel();
    setState(() => started = false);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Screen State Example app'),
        ),
        body: new Center(child: const Text('Turn screen on/off to see events.')),
        floatingActionButton: new FloatingActionButton(
          onPressed: started ? stopListening : startListening,
          tooltip: 'Start/Stop sensing',
          child: started ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}
