package cachet.plugins.appusage;

import android.content.Context;
import android.content.Intent;
import android.provider.Settings;

import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AppUsagePlugin
 */
public class AppUsagePlugin implements MethodCallHandler {
    /**
     * Plugin registration.
     */

    private static Context context;

    public static void registerWith(Registrar registrar) {
        AppUsagePlugin instance = new AppUsagePlugin();
        MethodChannel channel = new MethodChannel(registrar.messenger(), "app_usage.methodChannel");
        channel.setMethodCallHandler(instance);
        context = registrar.activeContext();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        // If permission not enabled, open the settings screen
        if (Stats.permissionRequired(context)) {
            Intent intent = new Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS);
            context.startActivity(intent);
        }

        long start = call.argument("start");
        long end = call.argument("end");
        HashMap<String, Double> usage = Stats.getUsageMap(context, start, end);

        if (call.method.equals("getUsage")) {
            result.success(usage);
        } else {
            result.notImplemented();
        }
    }
}
