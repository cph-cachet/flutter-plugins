import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<Activity> stream;
  Activity latestActivity = Activity.empty();

  @override
  void initState() {
    super.initState();
    stream = ActivityRecognition.activityUpdates();
    stream.listen(onData);
  }

  void onData(Activity activity) {
    setState(() {
      latestActivity = activity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Activity Recognition Example'),
        ),
        body: new Center(
          child: Text(latestActivity.toString()),
        ),
      ),
    );
  }
}
