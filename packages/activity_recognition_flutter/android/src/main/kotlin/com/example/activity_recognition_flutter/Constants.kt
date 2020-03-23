/*
 * Copyright (c) 2018. Daniel Morawetz
 * Licensed under Apache License v2.0
 */

package com.example.activity_recognition_flutter

class Constants {
    companion object {

        private val PACKAGE_NAME = "com.example.activity_recognition_flutter"

        val KEY_ACTIVITY_UPDATES_REQUESTED = "$PACKAGE_NAME.ACTIVITY_UPDATES_REQUESTED"

        val KEY_DETECTED_ACTIVITIES = "$PACKAGE_NAME.DETECTED_ACTIVITIES"

        /**
         * The desired time between activity detections. Larger values result in fewer activity
         * detections while improving battery life. A value of 0 results in activity detections at the
         * fastest possible rate.
         */
        const val DETECTION_INTERVAL_IN_MILLISECONDS: Long = 30 * 1000 // 30 seconds
    }
}