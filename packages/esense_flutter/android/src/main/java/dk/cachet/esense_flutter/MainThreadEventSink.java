package dk.cachet.esense_flutter;

import io.flutter.plugin.common.EventChannel.*;
import android.os.Handler;
import android.os.Looper;

public class MainThreadEventSink implements EventSink {
    private EventSink eventSink;
    private Handler handler;

    MainThreadEventSink(EventSink eventSink) {
        this.eventSink = eventSink;
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object o) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                eventSink.success(o);
            }
        });
    }

    @Override
    public void error(final String s, final String s1, final Object o) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                eventSink.error(s, s1, o);
            }
        });
    }

    @Override
    public void endOfStream() {
        handler.post(new Runnable() {
            @Override
            public void run() {
                eventSink.endOfStream();
            }
        });
    }
}
