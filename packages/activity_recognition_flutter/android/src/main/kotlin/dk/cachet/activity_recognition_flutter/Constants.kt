/*
 * Copyright (c) 2018. Daniel Morawetz
 * Licensed under Apache License v2.0
 */

package dk.cachet.activity_recognition_flutter

class Constants {
    companion object {
        private val PACKAGE_NAME = "dk.cachet.activity_recognition_flutter"
        val KEY_DETECTED_ACTIVITIES = "$PACKAGE_NAME.DETECTED_ACTIVITIES"
        const val DETECTION_INTERVAL_IN_MILLISECONDS: Long = 10 * 1000
    }
}