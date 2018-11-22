import 'dart:async';

import 'package:flutter/services.dart';

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

  Stream<NotificationEvent> get noiseStream {
    if (_notificationStream == null) {
      _notificationStream = _notificationEventChannel
          .receiveBroadcastStream()
          .map((event) => _notificationEvent(event));
    }
    return _notificationStream;
  }
}
