package dk.cachet.screen_state

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel


/** ScreenStatePlugin */
public class ScreenStatePlugin: FlutterPlugin, EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var eventChannel : EventChannel
  private var context: Context? = null
  private var mReceiver: ScreenReceiver? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "screenStateEvents")
    eventChannel.setStreamHandler(this);
    context = flutterPluginBinding.applicationContext;
  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    eventChannel.setStreamHandler(null);
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    val filter = IntentFilter()
    filter.addAction(Intent.ACTION_SCREEN_ON) // Turn on screen

    filter.addAction(Intent.ACTION_SCREEN_OFF) // Turn off Screen

    filter.addAction(Intent.ACTION_USER_PRESENT) // Unlock screen


    mReceiver = ScreenReceiver(events)
    context!!.registerReceiver(mReceiver, filter)
  }

  override fun onCancel(arguments: Any?) {
    eventChannel.setStreamHandler(null);
  }
}