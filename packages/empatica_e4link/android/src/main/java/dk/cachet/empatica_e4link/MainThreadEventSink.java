package dk.cachet.empatica_e4link;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.EventChannel.EventSink;

public class MainThreadEventSink implements EventSink {
    private final EventSink eventSink;
    private final Handler handler;

    MainThreadEventSink(EventSink eventSink) {
        this.eventSink = eventSink;
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object o) {
        handler.post(() -> eventSink.success(o));
    }

    @Override
    public void error(final String s, final String s1, final Object o) {
        handler.post(() -> eventSink.error(s, s1, o));
    }

    @Override
    public void endOfStream() {
        handler.post(eventSink::endOfStream);
    }
}
