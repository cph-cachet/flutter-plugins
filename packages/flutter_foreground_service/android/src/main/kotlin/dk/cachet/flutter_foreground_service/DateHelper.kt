package dk.cachet.flutter_foreground_service

import android.os.Build

class DateHelper: Comparable<DateHelper>{

    override fun compareTo(other: DateHelper): Int =
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val thisInstant = this.internalDate_O as java.time.Instant
            val thatInstant = other.internalDate_O as java.time.Instant

            thisInstant.compareTo(thatInstant)
        }
        else {
            this.internalDate.compareTo(other.internalDate)
        }

    private val internalDate_O: Any? by lazy{
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            java.time.Instant.now()
        }else{
            null
        }
    }

    private val internalDate = java.util.Calendar.getInstance()

    override fun toString(): String =
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            internalDate_O.toString()
        }else{
            internalDate.toString()
        }

    fun secondsUntil(otherDateHelper: DateHelper): Long =
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val thisInstant = this.internalDate_O as java.time.Instant
            val thatInstant = otherDateHelper.internalDate_O as java.time.Instant

            thisInstant.until(
                    thatInstant,
                    java.time.temporal.ChronoUnit.SECONDS
            )
        }else{
            (
                (
                    otherDateHelper.internalDate.timeInMillis
                            -
                    this.internalDate.timeInMillis
                )
                /
                1000
            )
        }
}