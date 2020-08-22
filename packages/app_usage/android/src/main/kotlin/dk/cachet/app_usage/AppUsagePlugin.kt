package dk.cachet.app_usage

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry


/** AppUsagePlugin */
public class AppUsagePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "app_usage")
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.applicationContext;

        Log.d("onAttachedToEngine","On attached");
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {


        if (Stats.permissionRequired(context)) {
            Log.d("onAttachedToEngine","Permission required ok")
//            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS);
//            context.applicationContext.startActivity(intent)
            context.startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
        }
        else {
            Log.d("onAttachedToEngine","Error with permissions")
        }

        val start: Long? = call.argument("start")
        val end: Long? = call.argument("end")
        Log.d("start", start.toString())
        Log.d("end", end.toString())
        val usage = Stats.getUsageMap(context, start!!, end!!)
        Log.d("onMethodCall", usage.toString());

        if (call.method == "getUsage") {
            result.success(usage)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
