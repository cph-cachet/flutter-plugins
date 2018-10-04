package cachet.sensors.light;

import android.annotation.TargetApi;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Build;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * SensorsPlugin
 */
public class LightPlugin implements EventChannel.StreamHandler {
  private static final String STEP_COUNT_CHANNEL_NAME =
          "flutter_light.eventChannel";

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final EventChannel eventChannel =
            new EventChannel(registrar.messenger(), STEP_COUNT_CHANNEL_NAME);
    eventChannel.setStreamHandler(
            new LightPlugin(registrar.context(), Sensor.TYPE_LIGHT));
  }

  private SensorEventListener sensorEventListener;
  private final SensorManager sensorManager;
  private final Sensor sensor;

  @TargetApi(Build.VERSION_CODES.CUPCAKE)
  private LightPlugin(Context context, int sensorType) {
    sensorManager = (SensorManager) context.getSystemService(context.SENSOR_SERVICE);
    sensor = sensorManager.getDefaultSensor(sensorType);
  }

  @TargetApi(Build.VERSION_CODES.CUPCAKE)
  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    sensorEventListener = createSensorEventListener(events);
    sensorManager.registerListener(sensorEventListener, sensor, sensorManager.SENSOR_DELAY_NORMAL);
  }

  @TargetApi(Build.VERSION_CODES.CUPCAKE)
  @Override
  public void onCancel(Object arguments) {
    sensorManager.unregisterListener(sensorEventListener);
  }

  SensorEventListener createSensorEventListener(final EventChannel.EventSink events) {
    return new SensorEventListener() {
      @Override
      public void onAccuracyChanged(Sensor sensor, int accuracy) {
      }

      @TargetApi(Build.VERSION_CODES.CUPCAKE)
      @Override
      public void onSensorChanged(SensorEvent event) {
        int lux = (int) event.values[0];
        events.success(lux);
      }
    };
  }
}
