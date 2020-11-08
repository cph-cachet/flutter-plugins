part of activity_recognition;

class _ARForegroundService {

  //use an async method so we can await
  static void start() async {
    ///if the app was killed+relaunched, this function will be executed again
    ///but if the foreground service stayed alive,
    ///this does not need to be re-done
    if (!(await ForegroundService.foregroundServiceIsStarted())) {
      await ForegroundService.setServiceIntervalSeconds(5);

      await ForegroundService.notification.startEditMode();

      await ForegroundService.notification
          .setTitle("Activity Recognition");
      await ForegroundService.notification
          .setText("Activity is being tracked");

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

  static void foregroundServiceFunction() {
    debugPrint("The current time is: ${DateTime.now()}");
    ForegroundService.notification.setText("The time was: ${DateTime.now()}");

    if (!ForegroundService.isIsolateCommunicationSetup) {
      ForegroundService.setupIsolateCommunication((data) {
        debugPrint("bg isolate received: $data");
      });
    }

    ForegroundService.sendToPort("message from bg isolate");
  }
}