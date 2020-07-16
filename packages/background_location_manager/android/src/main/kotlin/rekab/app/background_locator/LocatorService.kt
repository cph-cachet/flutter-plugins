package rekab.app.background_locator

import android.content.Context
import android.content.Intent
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.util.Log
import androidx.core.app.JobIntentService
import com.google.android.gms.location.LocationResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import io.flutter.view.FlutterNativeView
import io.flutter.view.FlutterRunArguments
import rekab.app.background_locator.Keys.Companion.ARG_ACCURACY
import rekab.app.background_locator.Keys.Companion.ARG_ALTITUDE
import rekab.app.background_locator.Keys.Companion.ARG_CALLBACK
import rekab.app.background_locator.Keys.Companion.ARG_HEADING
import rekab.app.background_locator.Keys.Companion.ARG_IS_MOCKED
import rekab.app.background_locator.Keys.Companion.ARG_TIME
import rekab.app.background_locator.Keys.Companion.ARG_LATITUDE
import rekab.app.background_locator.Keys.Companion.ARG_LOCATION
import rekab.app.background_locator.Keys.Companion.ARG_LONGITUDE
import rekab.app.background_locator.Keys.Companion.ARG_SPEED
import rekab.app.background_locator.Keys.Companion.ARG_SPEED_ACCURACY
import rekab.app.background_locator.Keys.Companion.BACKGROUND_CHANNEL_ID
import rekab.app.background_locator.Keys.Companion.BCM_SEND_LOCATION
import rekab.app.background_locator.Keys.Companion.CALLBACK_DISPATCHER_HANDLE_KEY
import rekab.app.background_locator.Keys.Companion.CALLBACK_HANDLE_KEY
import rekab.app.background_locator.Keys.Companion.METHOD_SERVICE_INITIALIZED
import rekab.app.background_locator.Keys.Companion.SHARED_PREFERENCES_KEY
import java.util.*
import java.util.concurrent.atomic.AtomicBoolean

class LocatorService : MethodChannel.MethodCallHandler, JobIntentService() {
    private val queue = ArrayDeque<HashMap<Any, Any>>()
    private lateinit var backgroundChannel: MethodChannel
    private lateinit var context: Context

    companion object {
        @JvmStatic
        private val JOB_ID = UUID.randomUUID().mostSignificantBits.toInt()

        @JvmStatic
        private var backgroundFlutterView: FlutterNativeView? = null

        @JvmStatic
        private val serviceStarted = AtomicBoolean(false)

        @JvmStatic
        private var pluginRegistrantCallback: PluginRegistrantCallback? = null

        @JvmStatic
        fun enqueueWork(context: Context, work: Intent) {
            enqueueWork(context, LocatorService::class.java, JOB_ID, work)
        }

        @JvmStatic
        fun setPluginRegistrant(callback: PluginRegistrantCallback) {
            pluginRegistrantCallback = callback
        }
    }

    override fun onCreate() {
        super.onCreate()
        startLocatorService(this)
    }

    private fun startLocatorService(context: Context) {
        // start synchronized block to prevent multiple service instant
        synchronized(serviceStarted) {
            this.context = context
            if (backgroundFlutterView == null) {
                val callbackHandle = context.getSharedPreferences(
                        SHARED_PREFERENCES_KEY,
                        Context.MODE_PRIVATE)
                        .getLong(CALLBACK_DISPATCHER_HANDLE_KEY, 0)
                val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)

                // We need flutter view to handle callback, so if it is not available we have to create a
                // Flutter background view without any view
                backgroundFlutterView = FlutterNativeView(context, true)

                val args = FlutterRunArguments()
                args.bundlePath = FlutterMain.findAppBundlePath()
                args.entrypoint = callbackInfo.callbackName
                args.libraryPath = callbackInfo.callbackLibraryPath

                backgroundFlutterView!!.runFromBundle(args)
                IsolateHolderService.setBackgroundFlutterViewManually(backgroundFlutterView)
            }

            pluginRegistrantCallback?.registerWith(backgroundFlutterView!!.pluginRegistry)
        }

        backgroundChannel = MethodChannel(backgroundFlutterView, BACKGROUND_CHANNEL_ID)
        backgroundChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_SERVICE_INITIALIZED -> {
                synchronized(serviceStarted) {
                    while (queue.isNotEmpty()) {
                        sendLocationEvent(queue.remove())
                    }
                    serviceStarted.set(true)
                }
            }
            else -> result.notImplemented()
        }

        result.success(null)
    }

    override fun onHandleWork(intent: Intent) {
        if (LocationResult.hasResult(intent)) {
            val location = LocationResult.extractResult(intent).lastLocation

            var speedAccuracy = 0f
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                speedAccuracy = location.speedAccuracyMetersPerSecond
            }
            var isMocked = false;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                isMocked = location.isFromMockProvider;
            }
            val locationMap: HashMap<Any, Any> =
                    hashMapOf(
                            ARG_IS_MOCKED to isMocked,
                            ARG_LATITUDE to location.latitude,
                            ARG_LONGITUDE to location.longitude,
                            ARG_ACCURACY to location.accuracy,
                            ARG_ALTITUDE to location.altitude,
                            ARG_SPEED to location.speed,
                            ARG_SPEED_ACCURACY to speedAccuracy,
                            ARG_HEADING to location.bearing,
                            ARG_TIME to location.time.toDouble())

            val callback = BackgroundLocatorPlugin.getCallbackHandle(context, CALLBACK_HANDLE_KEY)

            val result: HashMap<Any, Any> =
                    hashMapOf(ARG_CALLBACK to callback,
                            ARG_LOCATION to locationMap)

            synchronized(serviceStarted) {
                if (!serviceStarted.get()) {
                    queue.add(result)
                } else {
                    sendLocationEvent(result)
                }
            }
        }
    }

    private fun sendLocationEvent(result: HashMap<Any, Any>) {
        //https://github.com/flutter/plugins/pull/1641
        //https://github.com/flutter/flutter/issues/36059
        //https://github.com/flutter/plugins/pull/1641/commits/4358fbba3327f1fa75bc40df503ca5341fdbb77d
        // new version of flutter can not invoke method from background thread
        Handler(mainLooper)
                .post {
                    backgroundChannel.invokeMethod(BCM_SEND_LOCATION, result)
                }
    }
}