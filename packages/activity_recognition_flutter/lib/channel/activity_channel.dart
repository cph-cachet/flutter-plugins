/*
 * Copyright (c) 2018. Daniel Morawetz
 * Licensed under Apache License v2.0
 */

part of activity_recognition;

class _ActivityChannel {
  StreamController<Activity> _activityStreamController =
      StreamController<Activity>();
  StreamSubscription _activityUpdateStreamSubscription;

  Stream<Activity> get activityUpdates => _activityStreamController.stream;

  _ActivityChannel() {
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
    var parsedActivity = Activity.fromJson(json.decode(activity));
    _activityStreamController.add(parsedActivity);
  }

  static const MethodChannel _channel =
      const MethodChannel('activity_recognition/activities');

  static const EventChannel _eventChannel =
      const EventChannel('activity_recognition/activityUpdates');
}
