package cachet.plugins.notifications

import java.util.HashMap

/**
 * Flutter-specific
 */
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.PluginRegistry.Registrar

/**
 * Android-specific
 */
import android.content.*
import android.provider.Settings
import android.text.TextUtils

/**
 * NotificationsPlugin
 */
class NotificationsPlugin private constructor(private val context: Context) : StreamHandler {
    private var eventSink: EventSink? = null

    /**
     * Called whenever the event channel is subscribed to in Flutter
     */
    override fun onListen(o: Any?, eventSink: EventSink?) {
        this.eventSink = eventSink
        /*
          Start the notification service once permission has been given.
         */
        val listenerIntent = Intent(context, NotificationListener::class.java)
        context.startService(listenerIntent)
    }

    /**
     * Called whenever the event channel subscription is cancelled in Flutter
     */
    override fun onCancel(o: Any?) {
        eventSink = null
    }

    /**
     * For all enabled notification listeners, check if any of them matches the package name of this application.
     * If any match is found, return true. Otherwise if no matches were found, return false.
     */
    private fun permissionGiven(): Boolean {
        val packageName = context.packageName
        val flat = Settings.Secure.getString(context.contentResolver,
                ENABLED_NOTIFICATION_LISTENERS)
        if (!TextUtils.isEmpty(flat)) {
            val names = flat.split(":").toTypedArray()
            for (name in names) {
                val componentName = ComponentName.unflattenFromString(name)
                val nameMatch = TextUtils.equals(packageName, componentName?.packageName)
                if (nameMatch) {
                    return true
                }
            }
        }
        return false
    }

    internal inner class NotificationReceiver : BroadcastReceiver() {
        val TAG = "NOTIFICATION_RECEIVER"
        override fun onReceive(context: Context, intent: Intent) {
            val packageName = intent.getStringExtra(NotificationListener.NOTIFICATION_PACKAGE_NAME)
            val packageMessage = intent.getStringExtra(NotificationListener.NOTIFICATION_PACKAGE_MESSAGE)
            val map = HashMap<String, Any>()
            map["packageName"] = packageName
            map["packageMessage"] = packageMessage
            eventSink?.success(map)
        }
    }

    companion object {
        const val TAG = "NOTIFICATION_PLUGIN"
        private const val ENABLED_NOTIFICATION_LISTENERS = "enabled_notification_listeners"
        private const val ACTION_NOTIFICATION_LISTENER_SETTINGS = "android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"
        private const val EVENT_CHANNEL_NAME = "notifications.eventChannel"

        /** Plugin registration.  */
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = EventChannel(registrar.messenger(), EVENT_CHANNEL_NAME)
            val context: Context = registrar.activeContext()
            val plugin = NotificationsPlugin(context)
            channel.setStreamHandler(plugin)
        }
    }

    /**
     * Plugin constructor setting the context and registering the notification service.
     */
    init {
        /* Check if permission is given, if not then go to the notification settings screen. */
        if (!permissionGiven()) {
            context.startActivity(Intent(ACTION_NOTIFICATION_LISTENER_SETTINGS))
        }
        val receiver = NotificationReceiver()
        val intentFilter = IntentFilter()
        intentFilter.addAction(NotificationListener.NOTIFICATION_INTENT)
        context.registerReceiver(receiver, intentFilter)

        /* Start the notification service once permission has been given. */
        val listenerIntent = Intent(context, NotificationListener::class.java)
        context.startService(listenerIntent)
    }
}