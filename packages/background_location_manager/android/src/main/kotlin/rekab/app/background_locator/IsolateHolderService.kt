package rekab.app.background_locator

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterNativeView
import rekab.app.background_locator.Keys.Companion.ARG_NOTIFICATION_CHANNEL_NAME
import rekab.app.background_locator.Keys.Companion.ARG_DISPOSE_CALLBACK
import rekab.app.background_locator.Keys.Companion.ARG_INIT_CALLBACK
import rekab.app.background_locator.Keys.Companion.ARG_INIT_DATA_CALLBACK
import rekab.app.background_locator.Keys.Companion.ARG_NOTIFICATION_ICON
import rekab.app.background_locator.Keys.Companion.ARG_NOTIFICATION_ICON_COLOR
import rekab.app.background_locator.Keys.Companion.ARG_NOTIFICATION_MSG
import rekab.app.background_locator.Keys.Companion.ARG_NOTIFICATION_TITLE
import rekab.app.background_locator.Keys.Companion.ARG_WAKE_LOCK_TIME
import rekab.app.background_locator.Keys.Companion.BACKGROUND_CHANNEL_ID
import rekab.app.background_locator.Keys.Companion.BCM_DISPOSE
import rekab.app.background_locator.Keys.Companion.BCM_INIT
import rekab.app.background_locator.Keys.Companion.CHANNEL_ID
import rekab.app.background_locator.Keys.Companion.DISPOSE_CALLBACK_HANDLE_KEY
import rekab.app.background_locator.Keys.Companion.INIT_CALLBACK_HANDLE_KEY
import rekab.app.background_locator.Keys.Companion.INIT_DATA_CALLBACK_KEY
import rekab.app.background_locator.Keys.Companion.NOTIFICATION_ACTION

class IsolateHolderService : Service() {
    companion object {
        @JvmStatic
        val ACTION_SHUTDOWN = "SHUTDOWN"

        @JvmStatic
        val ACTION_START = "START"

        @JvmStatic
        private val WAKELOCK_TAG = "IsolateHolderService::WAKE_LOCK"

        @JvmStatic
        var backgroundFlutterView: FlutterNativeView? = null

        @JvmStatic
        fun setBackgroundFlutterViewManually(view: FlutterNativeView?) {
            backgroundFlutterView = view
            sendInit()
        }

        @JvmStatic
        var isRunning = false

        @JvmStatic
        var isSendedInit = false

        @JvmStatic
        var instance: Context? = null

        @JvmStatic
        fun sendInit() {
            if (backgroundFlutterView != null && instance != null && !isSendedInit) {
                val context = instance
                val initCallback = BackgroundLocatorPlugin.getCallbackHandle(context!!, INIT_CALLBACK_HANDLE_KEY)
                if (initCallback > 0) {
                    val initialDataMap = BackgroundLocatorPlugin.getDataCallback(context, INIT_DATA_CALLBACK_KEY)
                    val backgroundChannel = MethodChannel(backgroundFlutterView,
                            BACKGROUND_CHANNEL_ID)
                    Handler(context.mainLooper)
                            .post {
                                backgroundChannel.invokeMethod(BCM_INIT,
                                        hashMapOf(ARG_INIT_CALLBACK to initCallback, ARG_INIT_DATA_CALLBACK to initialDataMap))
                            }
                }
                isSendedInit = true
            }
        }
    }

    private var notificationChannelName = "Flutter Locator Plugin";
    private var notificationTitle = "Start Location Tracking"
    private var notificationMsg = "Track location in background"
    private var notificationIconColor = 0
    private var icon = 0
    private var wakeLockTime = 60 * 60 * 1000L // 1 hour default wake lock time

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun start() {
        if (isRunning) {
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Notification channel is available in Android O and up
            val channel = NotificationChannel(CHANNEL_ID, notificationChannelName,
                    NotificationManager.IMPORTANCE_LOW)

            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                    .createNotificationChannel(channel)
        }

        val intent = Intent(this, getMainActivityClass(this))
        intent.action = NOTIFICATION_ACTION

        val pendingIntent: PendingIntent = PendingIntent.getActivity(this, 1, intent, PendingIntent.FLAG_UPDATE_CURRENT)

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle(notificationTitle)
                .setContentText(notificationMsg)
                .setSmallIcon(icon)
                .setColor(notificationIconColor)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setContentIntent(pendingIntent)
                .build()

        (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
            newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG).apply {
                setReferenceCounted(false)
                acquire(wakeLockTime)
            }
        }

        instance = this
        sendInit()

        // Starting Service as foreground with a notification prevent service from closing
        startForeground(1, notification)

        isRunning = true
    }

    private fun stop() {
        instance = null
        isRunning = false
        isSendedInit = false
        if (backgroundFlutterView != null) {
            val context = this
            val disposeCallback = BackgroundLocatorPlugin.getCallbackHandle(context, DISPOSE_CALLBACK_HANDLE_KEY)
            if (disposeCallback > 0 && backgroundFlutterView != null) {
                val backgroundChannel = MethodChannel(backgroundFlutterView,
                        BACKGROUND_CHANNEL_ID)
                Handler(context.mainLooper)
                        .post {
                            backgroundChannel.invokeMethod(BCM_DISPOSE,
                                    hashMapOf(ARG_DISPOSE_CALLBACK to disposeCallback))
                        }
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            return super.onStartCommand(intent, flags, startId)
        }

        if (intent.action == ACTION_SHUTDOWN) {
            shutdownHolderService()
        } else if (intent.action == ACTION_START) {
            startHolderService(intent)
        }

        return START_STICKY
    }

    private fun startHolderService(intent: Intent) {
        notificationChannelName = intent.getStringExtra(ARG_NOTIFICATION_CHANNEL_NAME)
        notificationTitle = intent.getStringExtra(ARG_NOTIFICATION_TITLE)
        notificationMsg = intent.getStringExtra(ARG_NOTIFICATION_MSG)
        val iconNameDefault = "ic_launcher"
        var iconName = intent.getStringExtra(ARG_NOTIFICATION_ICON)
        if (iconName == null || iconName.isEmpty()) {
            iconName = iconNameDefault
        }
        icon = resources.getIdentifier(iconName, "mipmap", packageName)
        notificationIconColor = intent.getLongExtra(ARG_NOTIFICATION_ICON_COLOR, 0).toInt()
        wakeLockTime = intent.getIntExtra(ARG_WAKE_LOCK_TIME, 60) * 60 * 1000L
        start()
    }

    private fun shutdownHolderService() {
        (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
            newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG).apply {
                if (isHeld) {
                    release()
                }
            }
        }
        stopForeground(true)
        stopSelf()
        stop()
    }

    private fun getMainActivityClass(context: Context): Class<*>? {
        val packageName = context.packageName
        val launchIntent = context.packageManager.getLaunchIntentForPackage(packageName)
        val className = launchIntent?.component?.className ?: return null

        return try {
            Class.forName(className)
        } catch (e: ClassNotFoundException) {
            e.printStackTrace()
            null
        }
    }
}