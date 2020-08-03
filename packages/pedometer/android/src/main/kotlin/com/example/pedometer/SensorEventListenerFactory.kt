package com.example.pedometer


import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import io.flutter.plugin.common.EventChannel

fun sensorEventListener(events: EventChannel.EventSink): SensorEventListener? {
    return object : SensorEventListener {

        override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}

        override fun onSensorChanged(event: SensorEvent) {
            val stepCount = event.values[0].toInt()
            events.success(stepCount)
        }
    }
}