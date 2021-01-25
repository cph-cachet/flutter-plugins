package dk.cachet.activity_recognition_flutter;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import com.google.android.gms.location.ActivityRecognition;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;

/**
 * ActivityRecognitionFlutterPlugin
 */
public class ActivityRecognitionFlutterPlugin implements FlutterPlugin, EventChannel.StreamHandler, ActivityAware, SharedPreferences.OnSharedPreferenceChangeListener {
    private EventChannel channel;
    private EventChannel.EventSink eventSink;
    private Activity androidActivity;
    private Context androidContext;
    public static final String DETECTED_ACTIVITY = "detected_activity";
    public static final String ACTIVITY_RECOGNITION_KEY = "activity_recognition";

    private final String TAG = "activity_recognition";

    /**
     * The main function for starting activity tracking.
     * Handling events is done inside [ActivityRecognizedService]
     */
    private void startActivityTracking() {
        Log.d(TAG, "startActivityTracking");

        // Start the service
        Intent intent = new Intent(androidActivity, ActivityRecognizedService.class);
        PendingIntent pendingIntent = PendingIntent.getService(androidActivity, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);

        /// Frequency in milliseconds
        long frequency = 5 * 1000;
        Task<Void> task = ActivityRecognition.getClient(androidContext)
                .requestActivityUpdates(frequency, pendingIntent);

        task.addOnSuccessListener(new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(Void e) {
                Log.d(TAG, "ActivityRecognition: onSuccess");
            }
        });
        task.addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.d(TAG, "ActivityRecognition: onFailure");
            }
        });
    }

    /**
     * EventChannel.StreamHandler interface below
     */

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "activity_recognition");
    }


    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        startActivityTracking();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setStreamHandler(null);
    }

    @Override
    public void onCancel(Object arguments) {
        channel.setStreamHandler(null);
    }

    /**
     * ActivityAware interface below
     */
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        androidActivity = binding.getActivity();
        androidContext = binding.getActivity().getApplicationContext();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        androidActivity = null;
        androidContext = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        androidActivity = binding.getActivity();
        androidContext = binding.getActivity().getApplicationContext();

    }

    @Override
    public void onDetachedFromActivity() {
        androidActivity = null;
        androidContext = null;
    }

    /**
     * Shared preferences changed, i.e. latest activity
     */
    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
        if (key.equals(DETECTED_ACTIVITY)) {
            String result = sharedPreferences
                    .getString(DETECTED_ACTIVITY, "error");
            eventSink.success(result);
        }
    }
}
