package dk.cachet.empatica_e4link;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodChannel.Result;

public class MainThreadResult implements Result {
    private Result methodResult;
    private Handler handler;

    MainThreadResult(Result result) {
        this.methodResult = result;
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object result) {
        handler.post(
                () -> methodResult.success(result));
    }

    @Override
    public void error(
            final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(
                () -> methodResult.error(errorCode, errorMessage, errorDetails));
    }

    @Override
    public void notImplemented() {
        handler.post(
                () -> methodResult.notImplemented());
    }
}
