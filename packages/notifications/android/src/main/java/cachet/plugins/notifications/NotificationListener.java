package cachet.plugins.notifications;

import android.content.Intent;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;

/**
 * Notification listening service. Intercepts notifications if permission is given to do so.
 */
public class NotificationListener extends NotificationListenerService {

    public static String NOTIFICATION_INTENT = "notification_event";
    public static String NOTIFICATION_PACKAGE_NAME = "package_name";

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        String packageName = sbn.getPackageName();
        Intent intent = new  Intent(NOTIFICATION_INTENT);
        intent.putExtra(NOTIFICATION_PACKAGE_NAME, packageName);
        sendBroadcast(intent);
    }
}