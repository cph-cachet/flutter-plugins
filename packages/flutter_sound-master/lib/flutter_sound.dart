import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:flutter/services.dart';

class NoiseEvent {
  NoiseEvent(this.decibel);

  final num decibel;

  @override
  String toString() {
    return "[Decibel Reading: $decibel dB]";
  }
}

NoiseEvent _noiseEvent(num decibel) {
  return new NoiseEvent(decibel);
}

class Noise {
  static const MethodChannel _channel = const MethodChannel('flutter_sound');
  static const EventChannel _noiseEventChannel = EventChannel('noise.eventChannel');
  static StreamController<RecordStatus> _recorderController;

  Stream<RecordStatus> get onRecorderStateChanged => _recorderController.stream;
  bool _isRecording = false;

  Stream<NoiseEvent> _noiseStream;

  // A broadcast stream of events from the device.
  Stream<NoiseEvent> get noiseStream {
    if (_noiseStream == null) {
      _noiseStream = _noiseEventChannel
          .receiveBroadcastStream()
          .map((db) => _noiseEvent(db));
    }
    return _noiseStream;
  }

  Future<String> startRecorder(String uri) async {
    try {
      String pathResult =
          await _channel.invokeMethod('startRecorder', <String, dynamic>{
        'path': uri,
      });

      _setRecorderCallback();

      if (this._isRecording) {
        throw new Exception('Recorder is already recording.');
      }
      this._isRecording = true;
      return pathResult;
    } catch (err) {
      throw new Exception(err);
    }
  }

  Future<String> stopRecorder() async {
    if (!this._isRecording) {
      throw new Exception('Recorder already stopped.');
    }

    String result = await _channel.invokeMethod('stopRecorder');

    this._isRecording = false;
    _removeRecorderCallback();
    return result;
  }

  Future<String> setSubscriptionDuration(double sec) async {
    String result = await _channel
        .invokeMethod('setSubscriptionDuration', <String, dynamic>{
      'sec': sec,
    });
    return result;
  }

  Future<void> _setRecorderCallback() async {
    if (_recorderController == null) {
      _recorderController = new StreamController.broadcast();
    }
    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "updateRecorderProgress":
          Map<String, dynamic> result = json.decode(call.arguments);
          _recorderController.add(new RecordStatus.fromJSON(result));
          break;
        default:
          throw new ArgumentError('Unknown method ${call.method} ');
      }
    });
  }

  Future<void> _removeRecorderCallback() async {
    if (_recorderController != null) {
      _recorderController
        ..add(null)
        ..close();
      _recorderController = null;
    }
  }
}

class RecordStatus {
  final double currentPosition;

  RecordStatus.fromJSON(Map<String, dynamic> json)
      : currentPosition = double.parse(json['current_position']);

  @override
  String toString() {
    return 'currentPosition: $currentPosition';
  }
}
