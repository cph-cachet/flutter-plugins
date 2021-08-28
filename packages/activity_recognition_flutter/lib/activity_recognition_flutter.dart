library activity_recognition;

import 'dart:async';

import 'package:flutter/services.dart';

part 'ar_domain.dart';

/// Main entry to activity recognition API. Use as a singleton like
///
///   `ActivityRecognition.instance`
///
class ActivityRecognition {
  Stream<ActivityEvent>? _stream;

  ActivityRecognition._();

  static final ActivityRecognition _instance = ActivityRecognition._();

  static ActivityRecognition get instance => _instance;

  static const EventChannel _eventChannel =
  const EventChannel('activity_recognition_flutter');

  /// Requests continuous [ActivityEvent] updates.
  ///
  /// The Stream will output the *most probable* [ActivityEvent].
  /// By default the foreground service is enabled, which allows the
  /// updates to be streamed while the app runs in the background.
  /// The programmer can choose to not enable to foreground service.
  /// [notificationTitle] let you change notification foreground title, default is "MonsensoMonitor" ;(Just for ANDROID)
  /// [notificationDescription] let you change notification foreground description, default is "Monsenso Foreground Service" ;(Just for ANDROID)
  /// [detectionFrequency] let you change frequency of detections of activities in seconds, default is 5 ;(Just for ANDROID for now)
  Stream<ActivityEvent> startStream(
      {bool runForegroundService = true, String? notificationTitle, String? notificationDescription, int? detectionFrequency}) {
    if (_stream == null) {
      _stream = _eventChannel
          .receiveBroadcastStream({
        "foreground": runForegroundService,
        "notification_title": notificationTitle,
        "notification_desc": notificationDescription,
        "detection_frequency": detectionFrequency
      }).map(
              (json) => ActivityEvent.fromJson(json));
    }
    return _stream!;
  }
}
