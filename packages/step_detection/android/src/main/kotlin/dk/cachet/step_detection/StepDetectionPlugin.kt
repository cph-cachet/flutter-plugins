package dk.cachet.step_detection

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink


/** StepDetectionPlugin */
public class StepDetectionPlugin : FlutterPlugin, EventChannel.StreamHandler {
    private lateinit var channel: EventChannel
    private var sensorEventListener: SensorEventListener? = null
    private var sensorManager: SensorManager? = null
    private var sensor: Sensor? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = EventChannel(flutterPluginBinding.binaryMessenger, "step_detection")
        channel.setStreamHandler(this);
        val context = flutterPluginBinding.applicationContext
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager?
        sensor = sensorManager!!.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sensorEventListener = createSensorEventListener(events!!);
        sensorManager!!.registerListener(sensorEventListener, sensor, SensorManager.SENSOR_DELAY_FASTEST);
    }

    override fun onCancel(arguments: Any?) {
        sensorManager!!.unregisterListener(sensorEventListener);
    }

    fun createSensorEventListener(events: EventSink): SensorEventListener? {
        return object : SensorEventListener {
            override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}

            override fun onSensorChanged(event: SensorEvent) {
                val stepCount = event.values[0].toInt()
                events.success(stepCount)
            }
        }
    }
}
