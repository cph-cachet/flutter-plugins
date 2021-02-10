library flutter_foreground_service;

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

part 'src/foreground_service_handler.dart';

class ForegroundService {
  void start() async {
    if (Platform.isAndroid) {
      _initForegroundService();
    } else {
      debugPrint("Error: Can only use foreground services on Android!");
    }
  }

  void stop() async {
    if (Platform.isAndroid) {
      await ForegroundServiceHandler.stopForegroundService();
    } else {
      debugPrint("Error: Can only use foreground services on Android!");
    }
  }

  void _initForegroundService() async {
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

  void _callback() {
    ForegroundServiceHandler.notification
        .setText("The time was: ${DateTime.now()}");
    if (!ForegroundServiceHandler.isIsolateCommunicationSetup) {
      ForegroundServiceHandler.setupIsolateCommunication((data) {
        debugPrint("bg isolate received: $data");
      });
    }
    ForegroundServiceHandler.sendToPort("message from bg isolate");
  }
}
