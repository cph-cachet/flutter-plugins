package com.example.pedometer

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** PedometerPlugin */
class PedometerPlugin : FlutterPlugin {
    private lateinit var stepDetectionChannel: EventChannel
    private lateinit var stepCountChannel: EventChannel
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.pedometer").setMethodCallHandler {
                call, result ->
            val context = flutterPluginBinding.applicationContext
            val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
            if (call.method == "isStepDetectionSupported"){
                val stepDetectionSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
                result.success(stepDetectionSensor != null)

            }
            else if (call.method == "isStepCountSupported"){
                val stepCountSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
                result.success(stepCountSensor != null)
            }
        }
    }
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
