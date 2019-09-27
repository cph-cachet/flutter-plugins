package dk.cachet.esense_flutter;

import io.flutter.plugin.common.MethodChannel.*;
import android.os.Handler;
import android.os.Looper;

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
                new Runnable() {
                    @Override
                    public void run() {
                        methodResult.success(result);
                    }
                });
    }

    @Override
    public void error(
            final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        methodResult.error(errorCode, errorMessage, errorDetails);
                    }
                });
    }

    @Override
    public void notImplemented() {
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        methodResult.notImplemented();
                    }
                });
    }
}
