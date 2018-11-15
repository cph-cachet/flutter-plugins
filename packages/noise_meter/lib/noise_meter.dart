import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';

/** A [NoiseEvent] holds a decibel value for a particular noise level reading.**/
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

/** A [Noise] object is reponsible for connecting to to the native environment.
 * Uses a frequency (in milliseconds) for controlling how frequently readings
 * are received from the native environment**/

class Noise {
  Noise(this._frequency);

  int _frequency;

  static const EventChannel _noiseEventChannel =
  EventChannel('noiseLevel.eventChannel');

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