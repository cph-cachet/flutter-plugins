import 'package:flutter/material.dart';
import 'dart:async';
import 'package:notifications/notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Notifications notifications = new Notifications();
    StreamSubscription<NotificationEvent> events;
    events = notifications.stream.listen(onData);
  }

  void onData(NotificationEvent event) => print(event.toString());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
      ),
    );
  }
}
