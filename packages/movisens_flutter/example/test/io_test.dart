import 'dart:io';
import 'package:flutter/services.dart';

void main() async {
  // Create a temporary directory to work with
  final directory = await Directory.systemTemp.createTemp();

  // Mock out the MethodChannel for the path_provider plugin
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    // If we're getting the apps documents directory, return the path to the
    // temp directory on our test environment instead.
    if (methodCall.method == 'getApplicationDocumentsDirectory') {
      print(directory.path);
      return directory.path;
    }
    return null;
  });
}