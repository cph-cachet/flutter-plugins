import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_streamer/audio_streamer.dart';

//void main() {
//  const EventChannel channel = EventChannel('audio_streamer.eventChannel');
//
//  TestWidgetsFlutterBinding.ensureInitialized();
//
//  setUp(() {
//    channel.receiveBroadcastStream((MethodCall methodCall) async {
//      return '42';
//    });
//  });
//
//  tearDown(() {
//    channel.setMockMethodCallHandler(null);
//  });
//
//  test('getPlatformVersion', () async {
//    expect(await AudioStreamer.platformVersion, '42');
//  });
//}
