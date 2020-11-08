import 'package:flutter/material.dart';
import 'package:foreground_service/foreground_service.dart';

void main() {
  runApp(MyApp());

  maybeStartFGS();
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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _appMessage = "";

  @override
  void initState() {
    super.initState();
  }

  void _toggleForegroundServiceOnOff() async {
    final fgsIsRunning = await ForegroundService.foregroundServiceIsStarted();
    String appMessage;

    if (fgsIsRunning) {
      await ForegroundService.stopForegroundService();
      appMessage = "Stopped foreground service.";
    } else {
      maybeStartFGS();
      appMessage = "Started foreground service.";
    }

    setState(() {
      _appMessage = appMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Text('Foreground Service Example',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(8.0)),
            Text(_appMessage, style: TextStyle(fontStyle: FontStyle.italic))
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )),
        floatingActionButton: Column(
          children: <Widget>[
            FloatingActionButton(
              child: Text("F"),
              onPressed: _toggleForegroundServiceOnOff,
              tooltip: "Toggle Foreground Service On/Off",
            ),
            FloatingActionButton(
              child: Text("T"),
              onPressed: () async {
                if (await ForegroundService
                    .isBackgroundIsolateSetupComplete()) {
                  await ForegroundService.sendToPort("message from main");
                } else {
                  debugPrint("bg isolate setup not yet complete");
                }
              },
              tooltip: "Send test message to bg isolate from main app",
            )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ),
    );
  }
}
