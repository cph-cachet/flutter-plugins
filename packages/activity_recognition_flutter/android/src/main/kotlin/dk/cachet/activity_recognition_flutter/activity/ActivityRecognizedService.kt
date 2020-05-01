/*
 * Copyright (c) 2018. Daniel Morawetz
 * Licensed under Apache License v2.0
 */

package dk.cachet.activity_recognition_flutter.activity

import android.app.IntentService
import android.content.Context
import android.content.Intent
import android.os.Build
import android.preference.PreferenceManager
import android.util.Log
import dk.cachet.activity_recognition_flutter.Codec
import dk.cachet.activity_recognition_flutter.Constants
import com.google.android.gms.location.ActivityRecognitionResult

class ActivityRecognizedService(name: String = "ActivityRecognizedService") : IntentService(name) {

    val TAG = "ActivityRecognizedServi"

    override fun onHandleIntent(intent: Intent) {
        Log.d(TAG, "received activity update!")
        val result = ActivityRecognitionResult.extractResult(intent)

        // Get the list of the probable activities associated with the current state of the
        // device. Each activity is associated with a confidence level, which is an int between
        // 0 and 100.
        val detectedActivities = result.probableActivities as ArrayList


        val mostProbableActivity = detectedActivities.maxBy { it.confidence }

        val preferences =
                applicationContext.getSharedPreferences("activity_recognition", MODE_PRIVATE)
        preferences.edit().clear()
                .putString(
                        Constants.KEY_DETECTED_ACTIVITIES,
                        Codec.encodeResult(mostProbableActivity!!)
                )
                .apply()
    }
}