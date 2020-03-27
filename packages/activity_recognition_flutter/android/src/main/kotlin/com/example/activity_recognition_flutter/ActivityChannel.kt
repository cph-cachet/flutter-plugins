/*
 * Copyright (c) 2018. Daniel Morawetz
 * Licensed under Apache License v2.0
 */

package com.example.activity_recognition_flutter

import com.example.activity_recognition_flutter.activity.ActivityClient
import io.flutter.plugin.common.*

class ActivityChannel(private val activityClient: ActivityClient) :
        MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    fun register(messenger: BinaryMessenger) {
        val methodChannel = MethodChannel(messenger, "activity_recognition/activities")
        methodChannel.setMethodCallHandler(this)

        val eventChannel = EventChannel(messenger, "activity_recognition/activityUpdates")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startActivityUpdates" -> startActivityUpdates(result)
            else -> result.notImplemented()
        }
    }

    private fun startActivityUpdates(result: MethodChannel.Result) {
        activityClient.resume()
        result.success(true)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        activityClient.registerActivityUpdateCallback { result ->
            events.success(result)
        }
    }

    override fun onCancel(p0: Any?) {
        activityClient.deregisterLocationUpdatesCallback()
    }
}