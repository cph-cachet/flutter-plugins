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
    maybeStartFGS();
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

  //use an async method so we can await
  void maybeStartFGS() async {
    ///if the app was killed+relaunched, this function will be executed again
    ///but if the foreground service stayed alive,
    ///this does not need to be re-done
    if (!(await ForegroundService.foregroundServiceIsStarted())) {
      await ForegroundService.setServiceIntervalSeconds(5);

      //necessity of editMode is dubious (see function comments)
      await ForegroundService.notification.startEditMode();

      await ForegroundService.notification
          .setTitle("Example Title: ${DateTime.now()}");
      await ForegroundService.notification
          .setText("Example Text: ${DateTime.now()}");

      await ForegroundService.notification.finishEditMode();

      await ForegroundService.startForegroundService(foregroundServiceFunction);
      await ForegroundService.getWakeLock();
    }

    ///this exists solely in the main app/isolate,
    ///so needs to be redone after every app kill+relaunch
    await ForegroundService.setupIsolateCommunication((data) {
      debugPrint("main received: $data");
    });
  }

  void foregroundServiceFunction() {
    debugPrint("The current time is: ${DateTime.now()}");
    ForegroundService.notification.setText("The time was: ${DateTime.now()}");

    if (!ForegroundService.isIsolateCommunicationSetup) {
      ForegroundService.setupIsolateCommunication((data) {
        debugPrint("bg isolate received: $data");
      });
    }

    ForegroundService.sendToPort("message from bg isolate");
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
