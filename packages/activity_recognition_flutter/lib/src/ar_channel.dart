/*
 * Copyright (c) 2018. Daniel Morawetz
 * Licensed under Apache License v2.0
 */

part of activity_recognition;

class _ActivityChannel {
  StreamController<ActivityEvent> _activityStreamController =
      StreamController<ActivityEvent>();
  StreamSubscription _activityUpdateStreamSubscription;

  Stream<ActivityEvent> get activityUpdates => _activityStreamController.stream;

  bool _runForegroundService;

  _ActivityChannel(this._runForegroundService) {
    /// Start the foreground service plugin if we are on android
    /// and if the option was not toggled off by the programmer.
    if (Platform.isAndroid && _runForegroundService) {
      ForegroundService().start();
    }

    _activityStreamController.onListen = startActivityUpdates();
  }

  startActivityUpdates() {
    if (_activityUpdateStreamSubscription != null) return;

    _activityUpdateStreamSubscription = _eventChannel
        .receiveBroadcastStream()
        .listen(_onActivityUpdateReceived);

    _channel.invokeMethod('startActivityUpdates');
  }

  endActivityUpdates() {
    if (_activityUpdateStreamSubscription != null) {
      _activityUpdateStreamSubscription.cancel();
      _activityUpdateStreamSubscription = null;
    }
  }

  _onActivityUpdateReceived(dynamic activity) {
    debugPrint("onActivityUpdateReceived");
    assert(activity is String);
    var parsedActivity = ActivityEvent.fromJson(json.decode(activity));
    _activityStreamController.add(parsedActivity);
  }

  static const MethodChannel _channel =
      const MethodChannel('activity_recognition/activities');

  static const EventChannel _eventChannel =
      const EventChannel('activity_recognition/activityUpdates');
}
