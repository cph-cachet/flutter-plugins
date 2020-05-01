package dk.cachet.activity_recognition_flutter

import android.util.Log
import androidx.annotation.NonNull;
import dk.cachet.activity_recognition_flutter.activity.ActivityClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/*
 * Copyright (c) 2020. Thomas Nilsson
 * Licensed under Apache License v2.0
 */
/** ActivityRecognitionFlutterPlugin */
class ActivityRecognitionFlutterPlugin : FlutterPlugin, ActivityAware {

    lateinit var activityClient: ActivityClient
    lateinit var activityChannel: ActivityChannel
    lateinit var messenger: BinaryMessenger

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("Kotlin", "onAttachedToEngine")
        messenger = flutterPluginBinding.getFlutterEngine().getDartExecutor()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d("Kotlin", "onAttachedToActivity")
        activityClient = ActivityClient(binding.activity)
        activityChannel = ActivityChannel(activityClient)
        activityChannel.register(messenger)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

}
