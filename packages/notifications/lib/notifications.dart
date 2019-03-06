import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Custom Exception for the plugin,
/// thrown whenever the plugin is used on platforms other than Android
class NotificationException implements Exception {
  String _cause;

  NotificationException(this._cause);

  @override
  String toString() {
    return _cause;
  }
}

class NotificationEvent {
  String _packageName;
  DateTime _timeStamp;

  NotificationEvent(this._packageName) {
    _timeStamp = DateTime.now();
  }

  String get packageName => _packageName;

  DateTime get timeStamp => _timeStamp;

  @override
  String toString() {
    return "[$packageName sent notification @ $timeStamp";
  }
}

NotificationEvent _notificationEvent(String event) {
  return new NotificationEvent(event);
}

class Notifications {
  static const EventChannel _notificationEventChannel =
      EventChannel('notifications.eventChannel');

  Stream<NotificationEvent> _notificationStream;

  Stream<NotificationEvent> get notificationStream {
    if (Platform.isAndroid) {
      if (_notificationStream == null) {
        _notificationStream = _notificationEventChannel
            .receiveBroadcastStream()
            .map((event) => _notificationEvent(event));
      }
      return _notificationStream;
    }
    throw NotificationException(
        'Notification API exclusively available on Android!');
  }
}
