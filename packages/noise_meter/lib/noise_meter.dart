library noise_meter;

import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/services.dart';

/// A [NoiseReading] holds a decibel value for a particular noise level reading.
class NoiseReading {
  late double _meanDecibel, _maxDecibel;

  NoiseReading(List<double> volumes) {
    /// Sorted volumes such that the last element is max amplitude
    volumes.sort();

    /// Compute average peak-amplitude using the min and max amplitude
    double min = volumes.first;
    double max = volumes.last;
    double mean = 0.5 * (min.abs() + max.abs());

    /// Max amplitude is 2^15
    double maxAmp = pow(2, 15) + 0.0;

    _maxDecibel = 20 * log(maxAmp * max) * log10e;
    _meanDecibel = 20 * log(maxAmp * mean) * log10e;
  }

  double get maxDecibel => _maxDecibel;

  double get meanDecibel => _meanDecibel;

  @override
  String toString() {
    return '''[VolumeReading]
      - max dB    $maxDecibel
      - mean dB   $meanDecibel
    ''';
  }
}

/// A [NoiseMeter] object is reponsible for connecting to to
/// the native environment.
class NoiseMeter {
  AudioStreamer _streamer = AudioStreamer();
  Function _onError;
  Stream<NoiseReading>? _stream;

  NoiseMeter(this._onError);

  /// The rate at which the audio is sampled
  static int get sampleRate => AudioStreamer.sampleRate;

  late StreamController<NoiseReading> _controller;

  Stream<NoiseReading> get noiseStream {
    if (_stream == null) {
      _controller = StreamController<NoiseReading>.broadcast(
          onListen: _start, onCancel: _stop);
      _stream = _controller.stream.handleError(_onError);
    }
    return _stream!;
  }

  /// Whenever an array of PCM data comes in,
  /// they are converted to a [NoiseReading],
  /// and then send out via the stream
  void _onAudio(List<double> buffer) {
    _controller.add(NoiseReading(buffer));
  }

  void _onInternalError(PlatformException e) {
    _stream = null;
    _controller.addError(e);
  }

  /// Start noise monitoring.
  /// This will trigger a permission request
  /// if it hasn't yet been granted
  void _start() async {
    try {
      _streamer.start(_onAudio, _onInternalError);
    } catch (error) {
      print(error);
    }
  }

  /// Stop noise monitoring
  void _stop() async {
    await _streamer.stop();
  }
}
