import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';
import 'dart:math';

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

/** A [NoiseReading] holds a decibel value for a particular noise level reading.**/
class NoiseReading {

  double _db = 0;

  NoiseReading(List<dynamic> volumes) {
    /// Sorted volumes such that the last element is max amplitude
    volumes.sort();

    /// Compute average peak-amplitude using the min and max amplitude
    double min = volumes.first + 0.0;
    double max = volumes.last + 0.0;
    double avg = 0.5 * (min.abs() + max.abs());

    /// Max amplitude is 2^15
    double maxAmp = pow(2, 15) + 0.0;

    /// Calculate decibel values as 20 * log10(x)
    _db = 20 * log(maxAmp * avg) * log10e;
  }

  double get db => _db;

  @override
  String toString() {
    return "[VolumeReading: $db dB]";
  }
}

NoiseReading _noiseReading(List<dynamic> volumes) {
  return new NoiseReading(volumes);
}

/** A [NoiseMeter] object is reponsible for connecting to to the native environment.
 * Uses a frequency (in milliseconds) for controlling how frequently readings
 * are received from the native environment**/

class NoiseMeter {
  static const EventChannel _noiseEventChannel =
      EventChannel('noise_meter.eventChannel');

  Stream<NoiseReading> _noiseStream;

  Stream<NoiseReading> get noiseStream {
    if (_noiseStream == null) {
      _noiseStream = _noiseEventChannel
          .receiveBroadcastStream()
          .map((volumes) => _noiseReading(volumes));
    }
    return _noiseStream;
  }
}
