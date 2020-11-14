library activity_recognition;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:foreground_service/foreground_service.dart';
import 'dart:io' show Platform;

part 'package:activity_recognition_flutter/src/ar_channel.dart';

part 'package:activity_recognition_flutter/src/ar_domain.dart';

part 'package:activity_recognition_flutter/src/ar_foreground.dart';

class ActivityRecognition {
  static _ActivityChannel _channel;

  /// Requests continuous [ActivityEvent] updates.
  ///
  /// The Stream will output the *most probable* [ActivityEvent].
  /// By default the foreground service is enabled, which allows the
  /// updates to be streamed while the app runs in the background.
  /// The programmer can choose to not enable to foreground service,
  /// if they so choose.
  static Stream<ActivityEvent> activityStream(
      {bool runForegroundService = true}) {
    if (_channel == null) {
      _channel = _ActivityChannel(runForegroundService);
    }
    return _channel.activityUpdates;
  }
}
