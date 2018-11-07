package com.example.noise;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public interface NoiseInterface {
    void startRecorder(String path, MethodChannel.Result result, EventChannel.EventSink eventSink);
    void stopRecorder(MethodChannel.Result result);
}
