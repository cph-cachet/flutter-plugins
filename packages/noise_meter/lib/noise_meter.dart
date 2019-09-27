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
  NoiseEvent(this._volumes);

  List<dynamic> _volumes;

  List<dynamic> get volumes => _volumes;

  @override
  String toString() {
    return "[Volumes Reading: ${_volumes.toString()}]";
  }
}

NoiseEvent _noiseEvent(List<dynamic> volumes) {
  return new NoiseEvent(volumes);
}

/** A [NoiseMeter] object is reponsible for connecting to to the native environment.
 * Uses a frequency (in milliseconds) for controlling how frequently readings
 * are received from the native environment**/

class NoiseMeter {
  static const EventChannel _noiseEventChannel =
      EventChannel('noise_meter.eventChannel');

  Stream<NoiseEvent> _noiseStream;

  Stream<NoiseEvent> get noiseStream {
    if (_noiseStream == null) {
      _noiseStream = _noiseEventChannel
          .receiveBroadcastStream()
          .map((volumes) => _noiseEvent(volumes));
    }
    return _noiseStream;
  }
}
