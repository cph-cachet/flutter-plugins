package dk.cachet.notifications

/** Android-specific */
import android.content.*
import android.provider.Settings
import android.text.TextUtils
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink


/** NotificationsPlugin */
class NotificationsPlugin : FlutterPlugin, EventChannel.StreamHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var eventChannel: EventChannel
    private val ENABLED_NOTIFICATION_LISTENERS = "enabled_notification_listeners"
    private val ACTION_NOTIFICATION_LISTENER_SETTINGS = "android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"

    private val EVENT_CHANNEL_NAME = "notifications.eventChannel"

    private var eventSink: EventSink? = null
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this);
        context = flutterPluginBinding.applicationContext;
//        checkPermissions()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events;

        /* Check if permission is given, if not then go to the notification settings screen. */
//        checkPermissions()

        val receiver = NotificationReceiver(eventSink)
        val intentFilter = IntentFilter()
        intentFilter.addAction(NotificationListener.NOTIFICATION_INTENT)
        context!!.registerReceiver(receiver, intentFilter)

        /* Start the notification service once permission has been given. */
        val listenerIntent = Intent(context, NotificationListener::class.java)
        context!!.startService(listenerIntent)

    }

    override fun onCancel(arguments: Any?) {
    }

    private fun checkPermissions() {
        if (!permissionGiven()) {
            val intent = Intent(ACTION_NOTIFICATION_LISTENER_SETTINGS)
            context!!.startActivity(intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP))
        }
    }

    /**
     * For all enabled notification listeners, check if any of them matches the package name of this application.
     * If any match is found, return true. Otherwise if no matches were found, return false.
     */
    private fun permissionGiven(): Boolean {
        val packageName = context!!.packageName
        val flat: String = Settings.Secure.getString(context!!.contentResolver,
                ENABLED_NOTIFICATION_LISTENERS)
        if (!TextUtils.isEmpty(flat)) {
            val names = flat.split(":").toTypedArray()
            for (name in names) {
                val componentName = ComponentName.unflattenFromString(name)
                val nameMatch = TextUtils.equals(packageName, componentName.packageName)
                if (nameMatch) {
                    return true
                }
            }
        }
        return false
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (!permissionGiven()) {
            val intent = Intent(ACTION_NOTIFICATION_LISTENER_SETTINGS)
            binding.activity.startActivity(intent)
        }

        TODO("Not yet implemented")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }
}

