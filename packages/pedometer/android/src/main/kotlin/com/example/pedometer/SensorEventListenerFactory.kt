package com.example.pedometer

import android.app.Activity
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.EventChannel
import java.sql.Time
import java.time.LocalDateTime
import java.util.*
import kotlin.concurrent.timerTask

fun sensorEventListener(events: EventChannel.EventSink): SensorEventListener? {
    return object : SensorEventListener {

        var timer = Timer()
        var lastTime = LocalDateTime.now()

        override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}

        override fun onSensorChanged(event: SensorEvent) {
            lastTime = LocalDateTime.now()
                timer.schedule(timerTask {
                    if (lastTime.isBefore(LocalDateTime.now().plusSeconds(2)))
                    events.success(0)
                }, 2500)

            val stepCount = event.values[0].toInt()
            events.success(stepCount)
        }
    }
}