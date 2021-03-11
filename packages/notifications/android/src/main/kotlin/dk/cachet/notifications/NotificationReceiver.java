package dk.cachet.notifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel.EventSink;

class NotificationReceiver extends BroadcastReceiver {
    final static String TAG = "NOTIFICATION_RECEIVER";
    private EventSink eventSink;

    NotificationReceiver(EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String packageName = intent.getStringExtra(NotificationListener.NOTIFICATION_PACKAGE_NAME);
        String packageMessage = intent.getStringExtra(NotificationListener.NOTIFICATION_PACKAGE_MESSAGE);
        String userName = intent.getStringExtra(NotificationListener.NOTIFICATION_USER_NAME);
        String packageTitle = intent.getStringExtra(NotificationListener.NOTIFICATION_PACKAGE_TITLE);
        HashMap<String, Object> map = new HashMap<>();
        map.put("packageName", packageName);
        map.put("packageMessage", packageMessage);
        map.put("packageTitle", packageTitle);
        map.put("userName", userName);
        eventSink.success(map);
    }
}