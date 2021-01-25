package dk.cachet.activity_recognition_flutter;

import android.app.IntentService;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import com.google.android.gms.location.ActivityRecognitionResult;
import com.google.android.gms.location.DetectedActivity;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.List;
import java.util.function.Function;

import androidx.annotation.Nullable;

public class ActivityRecognizedService extends IntentService {

    private EventChannel.EventSink eventSink;

    public ActivityRecognizedService() {
        super("ActivityRecognizedService");
    }

    @Override
    public int onStartCommand(@Nullable Intent intent, int flags, int startId) {
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    protected void onHandleIntent(@Nullable Intent intent) {
        ActivityRecognitionResult result = ActivityRecognitionResult.extractResult(intent);
        List<DetectedActivity> activities = result.getProbableActivities();

        DetectedActivity mostLikely = activities.get(0);

        for (DetectedActivity a : activities) {
            if (a.getConfidence() > mostLikely.getConfidence()) {
                mostLikely = a;
            }
        }

        String type = getActivityString(mostLikely.getType());
        int confidence = mostLikely.getConfidence();

        String data = "{type: " + type + ", confidence: " + confidence + "}";

        SharedPreferences preferences =
                getApplicationContext().getSharedPreferences(ActivityRecognitionFlutterPlugin.ACTIVITY_RECOGNITION_KEY, MODE_PRIVATE);

        preferences.edit().clear()
                .putString(
                        ActivityRecognitionFlutterPlugin.DETECTED_ACTIVITY,
                        data
                )
                .apply();

    }

    public static String getActivityString(int type) {
        if (type == DetectedActivity.IN_VEHICLE) return "IN_VEHICLE";
        if (type == DetectedActivity.ON_BICYCLE) return "ON_BICYCLE";
        if (type == DetectedActivity.ON_FOOT) return "ON_FOOT";
        if (type == DetectedActivity.RUNNING) return "RUNNING";
        if (type == DetectedActivity.STILL) return "STILL";
        if (type == DetectedActivity.TILTING) return "TILTING";
        if (type == DetectedActivity.WALKING) return "WALKING";

        // Default case
        return "UNKNOWN";
    }
}