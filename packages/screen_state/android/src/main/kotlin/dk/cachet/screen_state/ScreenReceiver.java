package dk.cachet.screen_state;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import io.flutter.plugin.common.EventChannel.EventSink;

public class ScreenReceiver extends BroadcastReceiver {

    private EventSink eventSink;

    public ScreenReceiver(EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        eventSink.success(action);
    }
}