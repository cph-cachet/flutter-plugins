/*
 * Copyright (c) 2018. Daniel Morawetz
 * Licensed under Apache License v2.0
 */

package dk.cachet.activity_recognition_flutter.activity

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.Context.MODE_PRIVATE
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import dk.cachet.activity_recognition_flutter.Constants
import com.google.android.gms.location.ActivityRecognition


class ActivityClient(private val activity: Activity) :
        SharedPreferences.OnSharedPreferenceChangeListener {

    private val activityRecognitionClient = ActivityRecognition.getClient(activity)
    private var activityUpdatesCallback: ((String) -> Unit)? = null

    private var isPaused = true

    private val TAG = "ActivityClient"

    fun resume() {
        if (!isPaused) return

        registerSharedPreferenceChangeListener()
        requestActivityUpdates()

        isPaused = false
    }

    fun pause() {
        if (isPaused) return

        unregisterSharedPreferenceChangeListener()
        removeActivityUpdates()

        isPaused = true
    }

    fun registerActivityUpdateCallback(callback: (String) -> Unit) {
        activityUpdatesCallback = callback
    }

    fun deregisterLocationUpdatesCallback() {
        activityUpdatesCallback = null
    }

    private fun registerSharedPreferenceChangeListener() {
        val preferences =
                activity.applicationContext.getSharedPreferences("activity_recognition", MODE_PRIVATE)

        preferences.registerOnSharedPreferenceChangeListener(this)
    }

    private fun unregisterSharedPreferenceChangeListener() {
        val preferences =
                activity.applicationContext.getSharedPreferences("activity_recognition", MODE_PRIVATE)
        preferences.unregisterOnSharedPreferenceChangeListener(this)
    }

    @SuppressLint("MissingPermission")
    private fun requestActivityUpdates() {
        Log.d(TAG, "requestActivityUpdates: start")
        val task = activityRecognitionClient.requestActivityUpdates(
                Constants.DETECTION_INTERVAL_IN_MILLISECONDS,
                getActivityDetectionPendingIntent()
        )

        task.addOnSuccessListener {
            Log.d(TAG, "requestActivityUpdates: Activity Updates enabled successfully!")
        }

        task.addOnFailureListener {
            Log.d(TAG, "requestActivityUpdates: Failed to enable Activity updates: " + it.message)
        }
    }

    @SuppressLint("MissingPermission")
    private fun removeActivityUpdates() {
        val task = activityRecognitionClient.removeActivityUpdates(
                getActivityDetectionPendingIntent()
        )

        task.addOnSuccessListener {
            Log.d(TAG, "requestActivityUpdates: Activity Updates removed successfully!")
        }

        task.addOnFailureListener {
            Log.d(TAG, "requestActivityUpdates: Failed to remove Activity updates: " + it.message)
        }
    }

    private fun getActivityDetectionPendingIntent(): PendingIntent {
        val intent = Intent(activity, ActivityRecognizedService::class.java)


        // We use FLAG_UPDATE_CURRENT so that we get the same pending intent back when calling
        // requestActivityUpdates() and removeActivityUpdates().
        return PendingIntent.getService(activity, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
    }


    override fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences, key: String) {
        if (key == Constants.KEY_DETECTED_ACTIVITIES) {
            val result = sharedPreferences
                    .getString(Constants.KEY_DETECTED_ACTIVITIES, "")
            activityUpdatesCallback?.invoke(result)
        }
    }
}