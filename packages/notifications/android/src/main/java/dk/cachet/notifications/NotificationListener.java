package dk.cachet.notifications;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.content.Intent;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import androidx.annotation.RequiresApi;

/**
 * Notification listening service. Intercepts notifications if permission is given to do so.
 */
@SuppressLint("OverrideAbstract")
@RequiresApi(api = VERSION_CODES.JELLY_BEAN_MR2)
public class NotificationListener extends NotificationListenerService {

  public static String NOTIFICATION_INTENT = "notification_event";
  public static String NOTIFICATION_PACKAGE_NAME = "notification_package_name";
  public static String NOTIFICATION_MESSAGE = "notification_message";
  public static String NOTIFICATION_TITLE = "notification_title";

  @RequiresApi(api = VERSION_CODES.KITKAT)
  @Override
  public void onNotificationPosted(StatusBarNotification notification) {
    // Retrieve package name to set as title.
    String packageName = notification.getPackageName();
    // Retrieve extra object from notification to extract payload.
    Bundle extras = notification.getNotification().extras;

    // Pass data from one activity to another.
    Intent intent = new Intent(NOTIFICATION_INTENT);
    intent.putExtra(NOTIFICATION_PACKAGE_NAME, packageName);

    if (extras != null) {
      CharSequence title = extras.getCharSequence(Notification.EXTRA_TITLE);
      CharSequence text = extras.getCharSequence(Notification.EXTRA_TEXT);

      intent.putExtra(NOTIFICATION_TITLE, title.toString());
      intent.putExtra(NOTIFICATION_MESSAGE, text.toString());
    }
    sendBroadcast(intent);
  }
}
