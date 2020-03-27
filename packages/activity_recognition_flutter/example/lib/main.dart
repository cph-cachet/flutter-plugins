import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: StreamBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Activity act = snapshot.data;
                return Text("Your phone is to ${act.confidence}% ${act.type}!");
              }

              return Text("No activity detected.");
            },
            stream: ActivityRecognition.activityUpdates(),
          ),
        ),
      ),
    );
  }
}
