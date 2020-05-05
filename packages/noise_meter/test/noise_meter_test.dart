import 'package:flutter_test/flutter_test.dart';

import 'package:noise_meter/noise_meter.dart';

void main() {
  test('Sample rate test', () {
    NoiseMeter noiseMeter = NoiseMeter();
    expect(noiseMeter.sampleRate, 44100);
    print('Sample rate: ${noiseMeter.sampleRate}');
  });
}
