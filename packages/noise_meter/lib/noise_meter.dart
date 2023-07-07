library noise_meter;

import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/services.dart';

/// Holds a decibel value for a noise level reading.
class NoiseReading {
  late double _meanDecibel, _maxDecibel;

  NoiseReading(List<double> volumes) {
    // sorted volumes such that the last element is max amplitude
    volumes.sort();

    // compute average peak-amplitude using the min and max amplitude
    double min = volumes.first;
    double max = volumes.last;
    double mean = 0.5 * (min.abs() + max.abs());

    // max amplitude is 2^15
    double maxAmp = pow(2, 15) + 0.0;

    _maxDecibel = 20 * log(maxAmp * max) * log10e;
    _meanDecibel = 20 * log(maxAmp * mean) * log10e;
  }

  /// Maximum measured decibel reading.
  double get maxDecibel => _maxDecibel;

  /// Mean decibel across readings.
  double get meanDecibel => _meanDecibel;

  @override
  String toString() =>
      '$runtimeType - mean (dB): $meanDecibel, max (dB): $maxDecibel';
}

/// A [NoiseMeter] provides continuous access to noise reading via the [noise] stream.
class NoiseMeter {
  AudioStreamer _streamer = AudioStreamer();
  StreamController<NoiseReading>? _controller;
  Stream<NoiseReading>? _stream;

  /// The error callback function, if available.
  Function? onError;

  /// Create a [NoiseMeter].
  ///
  /// The [onError] callback must be of type `void Function(Object error)`
  /// or `void Function(Object error, StackTrace trace)`.
  NoiseMeter([this.onError]);

  /// The rate at which the audio is sampled
  static Future<int> get sampleRate => AudioStreamer().actualSampleRate;

  /// The stream of noise readings.
  Stream<NoiseReading> get noise {
    if (_stream == null) {
      _controller = StreamController<NoiseReading>.broadcast(
          onListen: _start, onCancel: _stop);
      _stream = (onError != null)
          ? _controller!.stream.handleError(onError!)
          : _controller!.stream;
    }
    return _stream!;
  }

  /// Whenever an array of PCM data comes in, they are converted to a [NoiseReading],
  /// and then send out via the stream
  void _onAudio(List<double> buffer) => _controller?.add(NoiseReading(buffer));

  void _onInternalError(PlatformException e) {
    _stream = null;
    _controller?.addError(e);
  }

  /// Start noise monitoring.
  /// This will trigger a permission request if it hasn't yet been granted
  void _start() async {
    try {
      _streamer.start(_onAudio, _onInternalError);
    } catch (error) {
      print(error);
    }
  }

  /// Stop noise monitoring
  void _stop() async => await _streamer.stop();
}
