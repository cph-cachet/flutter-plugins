package cachet.plugins.notifications

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/**
 * Notification listening service. Intercepts notifications if permission is given to do so.
 */
class NotificationListener : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        // Retrieve package name to set as title.
        val packageName = sbn.packageName
        // Retrieve extra object from notification to extract payload.
        val extras = sbn.notification.extras
        val packageMessage = extras?.getCharSequence(Notification.EXTRA_TEXT).toString()
        // Pass data from one activity to another.
        val intent = Intent(NOTIFICATION_INTENT)
        intent.putExtra(NOTIFICATION_PACKAGE_NAME, packageName)
        intent.putExtra(NOTIFICATION_PACKAGE_MESSAGE, packageMessage)
        sendBroadcast(intent)
    }

    companion object {
        const val NOTIFICATION_INTENT = "notification_event"
        const val NOTIFICATION_PACKAGE_NAME = "package_name"
        const val NOTIFICATION_PACKAGE_MESSAGE = "package_message"
    }
}