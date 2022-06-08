package dk.cachet.empatica_e4link;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class EmpaticaFlutterPlugin implements FlutterPlugin {
    static final String methodChannelName = "empatica.io/empatica_methodChannel";
    static final String dataEventSinkName = "empatica.io/empatica_dataEventSink";
    static final String statusEventSinkName = "empatica.io/empatica_statusEventSink";
    private MethodChannel methodChannel;
    EventChannel statusEventChannel;
    EventChannel dataEventChannel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Context context = binding.getApplicationContext();

        final EmpaStatusEventStreamHandler empaStatusEventStreamHandler = new EmpaStatusEventStreamHandler();
        final EmpaDataEventStreamHandler empaDataEventStreamHandler = new EmpaDataEventStreamHandler();
        final EmpaManagerMethodCallHandler empaMethodCallHandler = new EmpaManagerMethodCallHandler(
                empaDataEventStreamHandler, empaStatusEventStreamHandler, context);

        methodChannel = new MethodChannel(binding.getBinaryMessenger(), methodChannelName);
        methodChannel.setMethodCallHandler(empaMethodCallHandler);

        dataEventChannel = new EventChannel(binding.getBinaryMessenger(), dataEventSinkName);
        dataEventChannel.setStreamHandler(empaDataEventStreamHandler);

        statusEventChannel = new EventChannel(binding.getBinaryMessenger(), statusEventSinkName);
        statusEventChannel.setStreamHandler(empaStatusEventStreamHandler);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        dataEventChannel.setStreamHandler(null);
        statusEventChannel.setStreamHandler(null);
    }

}
