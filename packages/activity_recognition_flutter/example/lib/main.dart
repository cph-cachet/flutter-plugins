import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:foreground_service/foreground_service.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<Activity> activityStream;
  Activity latestActivity = Activity.empty();

  @override
  void initState() {
    super.initState();
    _init();

  }

  void _init() async {
    if (await Permission.activityRecognition.request().isGranted) {
      activityStream = ActivityRecognition.activityUpdates();
      activityStream.listen(onData);
    }
  }

  void onData(Activity activity) {
    print(activity.toString());
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
