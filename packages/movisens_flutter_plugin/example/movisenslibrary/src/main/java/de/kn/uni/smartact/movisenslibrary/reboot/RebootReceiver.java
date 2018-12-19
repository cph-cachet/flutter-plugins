package de.kn.uni.smartact.movisenslibrary.reboot;

import android.content.Context;
import android.content.Intent;
import android.support.v4.content.WakefulBroadcastReceiver;
import android.util.Log;

import de.kn.uni.smartact.movisenslibrary.bluetooth.MovisensService;

/**
 * Created by Simon on 7/08/2018.
 * <p/>
 * Handles Broadcast of the alarm; takes alarm event and passes it to the service class (which enables it to do it the background)
 */
public class RebootReceiver extends WakefulBroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (!MovisensService.isServiceRunning(context.getApplicationContext())) {
            final Intent gattServiceIntent = new Intent(context.getApplicationContext(), MovisensService.class);
            context.getApplicationContext().startService(gattServiceIntent);
        }
    }

}
