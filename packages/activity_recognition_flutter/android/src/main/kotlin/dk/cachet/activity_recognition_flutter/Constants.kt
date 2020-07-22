/*
 * Copyright (c) 2018. Daniel Morawetz
 * Licensed under Apache License v2.0
 */

package dk.cachet.activity_recognition_flutter

class Constants {
    companion object {

        private val PACKAGE_NAME = "dk.cachet.activity_recognition_flutter"
        val KEY_DETECTED_ACTIVITIES = "$PACKAGE_NAME.DETECTED_ACTIVITIES"

        /**
         * The desired time between activity detections. Larger values result in fewer activity
         * detections while improving battery life. A value of 0 results in activity detections at the
         * fastest possible rate.
         */
        const val DETECTION_INTERVAL_IN_MILLISECONDS: Long = 1000
    }
}