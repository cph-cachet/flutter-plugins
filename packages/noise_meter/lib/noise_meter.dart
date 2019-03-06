import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Custom Exception for the plugin,
/// thrown whenever the plugin is used on platforms other than Android
class NoiseMeterException implements Exception {
  String _cause;
  NoiseMeterException(this._cause);

  @override
  String toString() {
    return _cause;
  }
}

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

  static const EventChannel _noiseEventChannel =
  EventChannel('noiseLevel.eventChannel');

  int _frequency;
  Stream<NoiseEvent> _noiseStream;

  Stream<NoiseEvent> get noiseStream {
    if (Platform.isAndroid) {
      Map<String, dynamic> args = {'frequency': '$_frequency'};
      if (_noiseStream == null) {
        _noiseStream = _noiseEventChannel
            .receiveBroadcastStream(args)
            .map((db) => _noiseEvent(db));
      }
      return _noiseStream;
    }
    throw NoiseMeterException('Noise Meter currently only implemented for Android!');
  }
}