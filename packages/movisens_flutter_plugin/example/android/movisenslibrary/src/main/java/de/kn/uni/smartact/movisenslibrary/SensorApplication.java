package de.kn.uni.smartact.movisenslibrary;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.os.Handler;

import net.danlew.android.joda.JodaTimeAndroid;

/**
 * Created by Simon on 17.02.2016.
 */
public class SensorApplication extends Application implements Application.ActivityLifecycleCallbacks {

    public static final Boolean DEBUG = true;

    @Override
    public void onCreate() {
        super.onCreate();
        JodaTimeAndroid.init(this);

        registerActivityLifecycleCallbacks(this);
        handler = new Handler(getMainLooper());
    }


    public static boolean isLoggedIn = true;

    private Handler handler;
    private Runnable runLogout = new Runnable() {
        @Override
        public void run() {
            //isLoggedIn = false;
        }
    };

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        handler.removeCallbacks(runLogout);
    }

    @Override
    public void onActivityStarted(Activity activity) {
        handler.removeCallbacks(runLogout);
    }

    @Override
    public void onActivityResumed(Activity activity) {
        handler.removeCallbacks(runLogout);
    }

    @Override
    public void onActivityPaused(Activity activity) {
        handler.postDelayed(runLogout, 1000);
    }

    @Override
    public void onActivityStopped(Activity activity) {

    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {

    }

    @Override
    public void onActivityDestroyed(Activity activity) {

    }

}
