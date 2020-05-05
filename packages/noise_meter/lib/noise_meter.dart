library noise_meter;

import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:audio_streamer/audio_streamer.dart';

/** A [NoiseReading] holds a decibel value for a particular noise level reading.**/
class NoiseReading {
  double _db = 0;

  NoiseReading(List<double> volumes) {
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

/** A [NoiseMeter] object is reponsible for connecting to to
 *  the native environment.**/

class NoiseMeter {
  AudioStreamer _streamer = AudioStreamer();
  bool _isRecording = false;
  List<double> _audio = [];

  /// The rate at which the audio is sampled
  int get sampleRate => _streamer.sampleRate;

  StreamController<NoiseReading> _controller;

  Stream<NoiseReading> get noiseStream {
    _controller = StreamController<NoiseReading>.broadcast(
        onListen: _start, onCancel: _stop);
    return _controller.stream;
  }

  /// Whenever an array of PCM data comes in,
  /// they are converted to a [NoiseReading],
  /// and then send out via the stream
  void _onAudio(List<double> buffer) {
    _controller.add(NoiseReading(buffer));
  }

  /// Start noise monitoring.
  /// This will trigger a permission request
  /// if it hasn't yet been granted
  void _start() async {
    try {
      _streamer.start(_onAudio);
      _isRecording = true;
    } catch (error) {
      print(error);
    }
  }

  /// Stop noise monitoring
  void _stop() async {
    _isRecording = await _streamer.stop();
  }
}
