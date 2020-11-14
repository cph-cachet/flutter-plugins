library flutter_foreground_service;

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

part 'src/foreground_service_handler.dart';

class ForegroundService {

  void start() async {
    if (!(await ForegroundServiceHandler.foregroundServiceIsStarted())) {
      await ForegroundServiceHandler.setServiceIntervalSeconds(5);
      await ForegroundServiceHandler.startForegroundService(_callback);
      await ForegroundServiceHandler.getWakeLock();
    }

    ///this exists solely in the main app/isolate,
    ///so needs to be redone after every app kill+relaunch
    await ForegroundServiceHandler.setupIsolateCommunication((data) {
      debugPrint("main received: $data");
    });
  }

  void stop() async {
    await ForegroundServiceHandler.stopForegroundService();
  }

  void _callback() {
    ForegroundServiceHandler.notification.setText("The time was: ${DateTime.now()}");
    if (!ForegroundServiceHandler.isIsolateCommunicationSetup) {
      ForegroundServiceHandler.setupIsolateCommunication((data) {
        debugPrint("bg isolate received: $data");
      });
    }
    ForegroundServiceHandler.sendToPort("message from bg isolate");
  }
}