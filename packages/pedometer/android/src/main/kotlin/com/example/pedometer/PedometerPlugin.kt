package com.example.pedometer

import android.hardware.Sensor
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.os.Handler
import android.app.Activity
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.content.Context
import android.content.Intent
import com.example.pedometer.PermissionManager
import com.example.pedometer.PermissionResultCallback
import android.content.pm.PackageManager
import android.os.Build

const val CHANNEL_NAME = "pedometer"

/** PedometerPlugin */
class PedometerPlugin(private var channel: MethodChannel? = null) : MethodCallHandler, ActivityResultListener, Result, ActivityAware, FlutterPlugin {
    private val permissionManager: PermissionManager = PermissionManager();

    private var result: Result? = null
    private var mResult: Result? = null
    private var handler: Handler? = null
    private var activity: Activity? = null

    private lateinit var stepDetectionChannel: EventChannel
    private lateinit var stepCountChannel: EventChannel
    private lateinit var context: Context
    private lateinit var pluginBinding: ActivityPluginBinding

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

        /// MethodCall
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME);
        channel!!.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        stepDetectionChannel.setStreamHandler(null)
        stepCountChannel.setStreamHandler(null)

        channel = null
        activity = null
    }

    override fun success(p0: Any?) {
        handler?.post(
                Runnable { result?.success(p0) })
    }

    override fun notImplemented() {
        handler?.post(
                Runnable { result?.notImplemented() })
    }

    override fun error(
            errorCode: String, errorMessage: String?, errorDetails: Any?) {
        handler?.post(
                Runnable { result?.error(errorCode, errorMessage, errorDetails) })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return false
    }

    /// Handle calls from the MethodChannel
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isSensorAvailable" -> isSensorAvailable(call, result)
            "checkPermission" -> checkPermission(result)
            "requestPermission" -> requestPermission(result)
            else -> result.notImplemented()
        }
    }

    /// check if sensor is available
    private fun isSensorAvailable(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }

        mResult = result
        var sensorType = getSensorType(call)
        val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        if (sensorManager!!.getDefaultSensor(sensorType) == null) {
            mResult?.success(false)
            return
        }
        mResult?.success(true)
    }

    private fun getSensorType(call: MethodCall) : Int {
        val args = call.arguments as HashMap<*, *>
        val type = args["type"] as String
        if (type == "StepCount") {
            return Sensor.TYPE_STEP_COUNTER
        }
        return Sensor.TYPE_STEP_DETECTOR
    }

    private fun checkPermission(result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }

        mResult = result

        /// not needed before Android 9
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
            mResult?.success(true)
            return
        }

        mResult?.success(permissionManager.checkPermission(context))
    }

    private fun requestPermission(result: Result) {
        val callback = object: PermissionResultCallback {
            override fun onResult(permission: Boolean) {
                result.success(permission)
            }
        }
        permissionManager.requestPermission(activity, callback)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (channel == null) {
            return
        }
        this.pluginBinding = binding
        this.pluginBinding.addRequestPermissionsResultListener(this.permissionManager);
        binding.addActivityResultListener(this)
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        if (channel == null) {
            return
        }
        activity = null
        if (pluginBinding != null) {
            this.pluginBinding.removeRequestPermissionsResultListener(this.permissionManager);
        }
    }
}
