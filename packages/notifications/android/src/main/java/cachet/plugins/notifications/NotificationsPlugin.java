package cachet.plugins.notifications;

import java.util.HashMap;

/**
 * Flutter-specific
 */

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.EventChannel.EventSink;

/** Android-specific */
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

/**
 * NotificationsPlugin
 */
public class NotificationsPlugin implements EventChannel.StreamHandler {

    public static String TAG = "NOTIFICATION_PLUGIN";

    private static final String ENABLED_NOTIFICATION_LISTENERS = "enabled_notification_listeners";
    private static final String ACTION_NOTIFICATION_LISTENER_SETTINGS = "android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS";
    private EventSink eventSink;
    private Context context;
    private static final String EVENT_CHANNEL_NAME = "notifications.eventChannel";

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final EventChannel channel = new EventChannel(registrar.messenger(), EVENT_CHANNEL_NAME);
        Context context = registrar.activeContext();
        NotificationsPlugin plugin = new NotificationsPlugin(context);
        channel.setStreamHandler(plugin);
    }

    /**
     * Plugin constructor setting the context and registering the notification service.
     */
    private NotificationsPlugin(Context context) {
        this.context = context;

        /* Check if permission is given, if not then go to the notification settings screen. */
        if (!permissionGiven()) {
            context.startActivity(new Intent(ACTION_NOTIFICATION_LISTENER_SETTINGS));
        }

        NotificationReceiver receiver = new NotificationReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(NotificationListener.NOTIFICATION_INTENT);
        context.registerReceiver(receiver, intentFilter);

        /* Start the notification service once permission has been given. */
        Intent listenerIntent = new Intent(context, NotificationListener.class);
        context.startService(listenerIntent);
    }

    /** Called whenever the event channel is subscribed to in Flutter */
    @Override
    public void onListen(Object o, EventSink eventSink) {
        this.eventSink = eventSink;
        /*
          Start the notification service once permission has been given.
         */
        Intent listenerIntent = new Intent(context, NotificationListener.class);
        context.startService(listenerIntent);

    }

    /** Called whenever the event channel subscription is cancelled in Flutter */
    @Override
    public void onCancel(Object o) {
        this.eventSink = null;
    }

    /**
     * For all enabled notification listeners, check if any of them matches the package name of this application.
     * If any match is found, return true. Otherwise if no matches were found, return false.
     */
    private boolean permissionGiven() {
        String packageName = context.getPackageName();
        String flat = Settings.Secure.getString(context.getContentResolver(),
                ENABLED_NOTIFICATION_LISTENERS);
        if (!TextUtils.isEmpty(flat)) {
            String[] names = flat.split(":");
            for (String name : names) {
                ComponentName componentName = ComponentName.unflattenFromString(name);
                boolean nameMatch = TextUtils.equals(packageName, componentName.getPackageName());
                if (nameMatch) {
                    return true;
                }
            }
        }
        return false;
    }

    class NotificationReceiver extends BroadcastReceiver {
        final static String TAG = "NOTIFICATION_RECEIVER";
        @Override
        public void onReceive(Context context, Intent intent) {
            String packageName = intent.getStringExtra(NotificationListener.NOTIFICATION_PACKAGE_NAME);
            String packageMessage = intent.getStringExtra(NotificationListener.NOTIFICATION_PACKAGE_MESSAGE);
            HashMap<String, Object> map = new HashMap<>();
            map.put("packageName",packageName);
            map.put("packageMessage", packageMessage);
            eventSink.success(map);
        }
    }
}






