package cachet.plugins.screenstate;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ScreenStatePlugin */
public class ScreenStatePlugin implements EventChannel.StreamHandler {
  private Context context;
  private ScreenReceiver mReceiver;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    ScreenStatePlugin plugin = new ScreenStatePlugin(registrar);
    final EventChannel eventChannel = new EventChannel(registrar.messenger(), "screenStateEvents");
    eventChannel.setStreamHandler(plugin);
  }

  private ScreenStatePlugin(Registrar registrar) {
    context = registrar.activeContext();
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    IntentFilter filter = new IntentFilter();
    filter.addAction(Intent.ACTION_SCREEN_ON); // Turn on screen
    filter.addAction(Intent.ACTION_SCREEN_OFF); // Turn off Screen
    filter.addAction(Intent.ACTION_USER_PRESENT); // Unlock screen

    mReceiver = new ScreenReceiver(eventSink);
    context.registerReceiver(mReceiver, filter);
  }

  @Override
  public void onCancel(Object o) {

  }
}

