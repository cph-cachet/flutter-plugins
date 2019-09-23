package dk.cachet.esense_flutter;

import android.Manifest;
import io.flutter.plugin.common.*;
import io.flutter.plugin.common.MethodChannel.*;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** EsenseFlutterPlugin */
public class EsenseFlutterPlugin {

  public static final String ESenseManagerMethodChannelName = "esense.io/esense_manager";
  public static final String ESenseConnectionEventChannelName = "esense.io/esense_connection";
  public static final String ESenseEventEventChannelName = "esense.io/esense_events";
  public static final String ESenseSensorEventChannelName = "esense.io/esense_sensor";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    registrar.activity().requestPermissions(new String[]{
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_FINE_LOCATION,
    }, 0);

    final  ESenseConnectionEventStreamHandler eSenseConnectionEventStreamHandler = new ESenseConnectionEventStreamHandler(registrar);
    final ESenseManagerMethodCallHandler eSenseManagerMethodCallHandler = new ESenseManagerMethodCallHandler(registrar,eSenseConnectionEventStreamHandler);

    final MethodChannel eSenseManagerMethodChannel = new MethodChannel(registrar.messenger(), ESenseManagerMethodChannelName);
    eSenseManagerMethodChannel.setMethodCallHandler(eSenseManagerMethodCallHandler);

    final EventChannel eSenseConnectionEventChannel = new EventChannel(registrar.messenger(), ESenseConnectionEventChannelName);
    eSenseConnectionEventChannel.setStreamHandler(eSenseConnectionEventStreamHandler);

    final EventChannel eSenseEventChannel = new EventChannel(registrar.messenger(), ESenseEventEventChannelName);
    eSenseEventChannel.setStreamHandler(new ESenseEventStreamHandler(eSenseManagerMethodCallHandler));

    final EventChannel eSenseSensorEventChannel = new EventChannel(registrar.messenger(), ESenseSensorEventChannelName);
    eSenseSensorEventChannel.setStreamHandler(new ESenseSensorEventStreamHandler(eSenseManagerMethodCallHandler));
  }
}
