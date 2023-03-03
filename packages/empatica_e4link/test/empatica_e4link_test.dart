// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:empatica_e4link/empatica_e4link.dart';

// void main() {
//   const MethodChannel channel = MethodChannel('empatica_e4link');

//   TestWidgetsFlutterBinding.ensureInitialized();

//   setUp(() {
//     channel.setMockMethodCallHandler((MethodCall methodCall) async {
//       return '42';
//     });
//   });

//   tearDown(() {
//     channel.setMockMethodCallHandler(null);
//   });

//   test('getPlatformVersion', () async {
//     expect(await EmpaticaE4link.platformVersion, '42');
//   });
// }
