import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class Pedometer {
  static const EventChannel _stepDetectionChannel =
      const EventChannel('step_detection');
  static const EventChannel _stepCountChannel =
      const EventChannel('step_count');


//  StreamController<StepDetectionEvent> detectionController;
//  static const oneSec = const Duration(seconds:1);


  /// Returns one step at a time.
  /// Events come every time a step is detected.
  static Future<Stream<StepDetectionEvent>> get stepDetectionStream async {

    Stream<StepDetectionEvent> stream = _stepDetectionChannel
        .receiveBroadcastStream()
        .map((event) => StepDetectionEvent._(event))
        .handleError(_onError);

    return stream;

//    if (Platform.isIOS) {
//      return stream;
//    }
//
//    detectionController.addStream(stream);
//    new Timer.periodic(oneSec, (Timer t) => print('hi!'));

  }


  /// Returns the steps taken since last system boot.
  /// Events may come with a delay.
  static Future<Stream<StepCountEvent>> get stepCountStream async =>
      _stepCountChannel
          .receiveBroadcastStream()
          .map((event) => StepCountEvent._(event))
          .handleError(_onError);

  static void _onError(dynamic e) {
    PlatformException exception = e as PlatformException;
    print('ERROR: ${exception.message}');
  }
}

/// A DTO for steps taken containing the number of steps taken.
class StepCountEvent {
  DateTime _timeStamp;
  int _steps = 0;

  StepCountEvent._(dynamic e) {
    _steps = e as int;
    _timeStamp = DateTime.now();
  }

  int get steps => _steps;

  DateTime get timeStamp => _timeStamp;

  @override
  String toString() =>
      'Steps taken: $_steps at ${_timeStamp.toIso8601String()}';
}

/// A DTO for steps taken containing a detected step and its corresponding
/// status, i.e. walking, stopped or unknown.
class StepDetectionEvent {
  static const _WALKING = 'walking';
  static const _STOPPED = 'stopped';
  static const _UNKNOWN = 'unknown';


  static const Map<int, String> _STATUSES = {0: _STOPPED, 1: _WALKING};

  DateTime _timeStamp;
  String _status = _UNKNOWN;

  StepDetectionEvent._(dynamic t) {
    int _type = t as int;
    _status = _STATUSES[_type];
    _timeStamp = DateTime.now();
  }

  String get steps => _status;

  DateTime get timeStamp => _timeStamp;

  @override
  String toString() =>
      'Status: $_status at ${_timeStamp.toIso8601String()}';
}
