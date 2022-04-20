package dk.cachet.empatica_e4link;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class EmpaticaFlutterPlugin implements FlutterPlugin {

    // Channel naming
    public static final String EmpaDeviceManagerMethodChannelName = "empatica.io/empatica_deviceManager";
    public static final String EmpaStatusDelegateEventChannelName = "empatica.io/empatica_statusDelegate";
    public static final String EmpaDataDelegateEventChannelName = "empatica.io/empatica_dataDelegate";

    /// The MethodChannel and EventChannels that will the communication between Flutter and native Android
    private MethodChannel channel;
    private Context context;
    private MethodChannel empaDeviceManagerMethodChannel;
    private EventChannel empaStatusDelegateEventChannel;
    private EventChannel empaDataDelegateEventChannel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        final EmpaStatusDelegateEventStreamHandler empaStatusDelegateEventStreamHandler = new EmpaStatusDelegateEventStreamHandler();
        final EmpaDataDelegateEventStreamHandler empaDataDelegateStreamHandler = new EmpaDataDelegateEventStreamHandler();
        final EmpaDeviceManagerMethodCallHandler empaDeviceManagerCallHandler = new EmpaDeviceManagerMethodCallHandler(context, empaDataDelegateStreamHandler, empaStatusDelegateEventStreamHandler, channel);

        empaDeviceManagerMethodChannel = new MethodChannel(binding.getBinaryMessenger(), EmpaDeviceManagerMethodChannelName);
        empaDeviceManagerMethodChannel.setMethodCallHandler(empaDeviceManagerCallHandler);

        empaStatusDelegateEventChannel = new EventChannel(binding.getBinaryMessenger(), EmpaStatusDelegateEventChannelName);
        empaStatusDelegateEventChannel.setStreamHandler(empaStatusDelegateEventStreamHandler);

        empaDataDelegateEventChannel = new EventChannel(binding.getBinaryMessenger(),EmpaDataDelegateEventChannelName);
        empaDataDelegateEventChannel.setStreamHandler(empaDataDelegateStreamHandler);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        empaDeviceManagerMethodChannel.setMethodCallHandler(null);
        empaStatusDelegateEventChannel.setStreamHandler(null);
        empaDataDelegateEventChannel.setStreamHandler(null);
    }
}
