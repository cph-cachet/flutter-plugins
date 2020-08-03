package com.example.pedometer

import android.hardware.Sensor
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

/** PedometerPlugin */
class PedometerPlugin : FlutterPlugin {
    private lateinit var stepDetectionChannel: EventChannel
    private lateinit var stepCountChannel: EventChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        /// Create channels
        stepDetectionChannel = EventChannel(flutterPluginBinding.binaryMessenger, "step_detection")
        stepCountChannel = EventChannel(flutterPluginBinding.binaryMessenger, "step_count")

        /// Create handlers
        val stepDetectionHandler = SensorStreamHandler(flutterPluginBinding, Sensor.TYPE_STEP_DETECTOR)
        val stepCountHandler = SensorStreamHandler(flutterPluginBinding, Sensor.TYPE_STEP_COUNTER)

        /// Set handlers
        stepDetectionChannel.setStreamHandler(stepDetectionHandler)
        stepCountChannel.setStreamHandler(stepCountHandler)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        stepDetectionChannel.setStreamHandler(null)
        stepCountChannel.setStreamHandler(null)
    }

}
