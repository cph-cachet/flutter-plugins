import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';

class NoiseEvent {
  NoiseEvent(this._decibel);

  num _decibel;

  int get decibel => _decibel.round();

  @override
  String toString() {
    return "[Decibel Reading: $_decibel dB]";
  }
}

NoiseEvent _noiseEvent(num decibel) {
  return new NoiseEvent(decibel);
}

class Noise {
  Noise(this._frequency);

  int _frequency;

  static const EventChannel _noiseEventChannel =
      EventChannel('noise.eventChannel');

  Stream<NoiseEvent> _noiseStream;

  Stream<NoiseEvent> get noiseStream {
    Map<String, dynamic> args = {'frequency': '$_frequency'};
    if (_noiseStream == null) {
      _noiseStream = _noiseEventChannel
          .receiveBroadcastStream(args)
          .map((db) => _noiseEvent(db));
    }
    return _noiseStream;
  }
}
