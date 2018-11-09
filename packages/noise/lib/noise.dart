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
  static const MethodChannel _noiseMethodChannel =
      const MethodChannel('noise.methodChannel');
  static const EventChannel _noiseEventChannel =
      EventChannel('noise.eventChannel');
  bool _isRecording = false;

  Stream<NoiseEvent> _noiseStream;

  Stream<NoiseEvent> get noiseStream {
    Map<String, dynamic> args = {'arg': 500};
    if (_noiseStream == null) {
      _noiseStream = _noiseEventChannel
          .receiveBroadcastStream(args)
          .map((db) => _noiseEvent(db));
    }
    return _noiseStream;
  }

  Future<String> startRecorder(String uri) async {
    Map<String, dynamic> args = {'path': uri, 'frequency': 500};
    try {
      String pathResult =
          await _noiseMethodChannel.invokeMethod('startRecorder', args);

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

    String result = await _noiseMethodChannel.invokeMethod('stopRecorder');

    this._isRecording = false;
    return result;
  }
}
