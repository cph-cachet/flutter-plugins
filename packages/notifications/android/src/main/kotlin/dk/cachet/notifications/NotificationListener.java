package dk.cachet.notifications;

import android.app.Notification;
import android.content.Intent;
import android.os.Bundle;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;

/**
 * Notification listening service. Intercepts notifications if permission is given to do so.
 */
public class NotificationListener extends NotificationListenerService {

    public static String NOTIFICATION_INTENT = "notification_event";
    public static String NOTIFICATION_USER_NAME = "user_name";
    public static String NOTIFICATION_PACKAGE_NAME = "package_name";
    public static String NOTIFICATION_PACKAGE_MESSAGE = "package_message";
    public static String NOTIFICATION_PACKAGE_TITLE = "package_title";
    public static String NOTIFICATION_PACKAGE_EXTRA = "package_extra";

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        String userName = sbn.getUser().toString();
        // Retrieve package name to set as title.
        String packageName = sbn.getPackageName();
        // Retrieve extra object from notification to extract payload.
        Bundle extras = sbn.getNotification().extras;

        // Pass data from one activity to another.
        Intent intent = new Intent(NOTIFICATION_INTENT);
        intent.putExtra(NOTIFICATION_PACKAGE_NAME, packageName);
        
        if(userName != null){
            intent.putExtra(NOTIFICATION_USER_NAME, userName);
        }
        if (extras != null) {
            CharSequence extraTitle = extras.getCharSequence(Notification.EXTRA_TITLE);
            if (extraTitle != null)
            intent.putExtra(NOTIFICATION_PACKAGE_TITLE, extraTitle.toString());

            CharSequence extraText = extras.getCharSequence(Notification.EXTRA_TEXT);
            if (extraText != null)
                intent.putExtra(NOTIFICATION_PACKAGE_MESSAGE, extraText.toString());
        }
        sendBroadcast(intent);
    }
}