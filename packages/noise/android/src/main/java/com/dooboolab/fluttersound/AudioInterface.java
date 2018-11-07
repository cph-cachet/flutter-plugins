package com.dooboolab.fluttersound;

import io.flutter.plugin.common.MethodChannel;

interface AudioInterface {
  void startRecorder(String path, MethodChannel.Result result);
  void stopRecorder(MethodChannel.Result result);
}
