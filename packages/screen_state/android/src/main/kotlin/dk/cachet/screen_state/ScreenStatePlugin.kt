package dk.cachet.screen_state

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel


/** ScreenStatePlugin */
public class ScreenStatePlugin: FlutterPlugin, EventChannel.StreamHandler {
  private lateinit var eventChannel : EventChannel
  private var context: Context? = null
  private var screenReceiver: ScreenReceiver? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "screenStateEvents")
    context = flutterPluginBinding.applicationContext;
    eventChannel.setStreamHandler(this);

  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    eventChannel.setStreamHandler(null);
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    screenReceiver = ScreenReceiver(events)

    /// Create IntentFilter with the screen actions
    val filter = IntentFilter()
    filter.addAction(Intent.ACTION_SCREEN_ON) // Turn on screen
    filter.addAction(Intent.ACTION_SCREEN_OFF) // Turn off Screen
    filter.addAction(Intent.ACTION_USER_PRESENT) // Unlock screen

    /// Register
    context!!.registerReceiver(screenReceiver, filter)
  }

  override fun onCancel(arguments: Any?) {
    context!!.unregisterReceiver(screenReceiver)
  }
}