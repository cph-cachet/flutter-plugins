import 'package:flutter_test/flutter_test.dart';

import 'package:noise_meter/noise_meter.dart';

void main() {
  test('Sample rate test', () {
    expect(NoiseMeter.sampleRate, 44100);
    print('Sample rate: ${NoiseMeter.sampleRate}');
  });
}
