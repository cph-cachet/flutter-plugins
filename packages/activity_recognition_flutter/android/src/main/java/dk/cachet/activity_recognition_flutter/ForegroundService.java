package dk.cachet.activity_recognition_flutter;

import android.annotation.TargetApi;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.app.TaskStackBuilder;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.IBinder;

public class ForegroundService extends Service {

    public ForegroundService() {
        super();
    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        //get bundle of main intent of start action
        startPluginForegroundService(intent.getExtras());
        return START_STICKY;
    }

    /**
     * method for get main class for pending intent
     */
    private Class getMainActivityClass(Context context) {
        String packageName = context.getPackageName();
        Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
        String className = launchIntent.getComponent().getClassName();
        try {
            return Class.forName(className);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    @TargetApi(26)
    private void startPluginForegroundService(Bundle extras) {
        Context context = getApplicationContext();


        // Get notification channel importance
        Integer importance;

        try {
            importance = (Integer) extras.get("importance");
        } catch (Exception e) {
            importance = 1;
        }

        switch (importance) {
            case 2:
                importance = NotificationManager.IMPORTANCE_DEFAULT;
                break;
            case 3:
                importance = NotificationManager.IMPORTANCE_HIGH;
                break;
            default:
                importance = NotificationManager.IMPORTANCE_LOW;
                // We are not using IMPORTANCE_MIN because we want the notification to be visible
        }

        // Create notification channel
        NotificationChannel channel = new NotificationChannel("foreground.service.channel", "Background Services", importance);
        channel.setDescription("Enables background processing.");
        getSystemService(NotificationManager.class).createNotificationChannel(channel);

        // Get notification icon
//        int icon = getResources().getIdentifier((String) extras.get("icon"), "drawable", context.getPackageName());
        int icon = R.drawable.common_full_open_on_phone;
        /**
         * create pending intent for open app with click on foreground notification
         */
        TaskStackBuilder stackBuilder = TaskStackBuilder.create(this);
        stackBuilder.addNextIntent(new Intent(this, this.getPackageName().getClass()));
        Intent resultIntent = new Intent(this, getMainActivityClass(this));
        PendingIntent pendingIntentC = PendingIntent.getActivity(this, 66, resultIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        // Make notification
        Notification notification = new Notification.Builder(context, "foreground.service.channel")
                .setContentTitle((CharSequence) extras.get("title"))
                .setContentText((CharSequence) extras.get("text"))
                .setOngoing(true)
                .setContentIntent(pendingIntentC)
                .setSmallIcon(icon == 0 ? 17301514 : icon) // Default is the star icon
                .build();

        // Get notification ID
        Integer id;
        try {
            id = (Integer) extras.get("id");
        } catch (Exception e) {
            id = 0;
        }

        // Put service in foreground and show notification (id of 0 is not allowed)
        startForeground(id != 0 ? id : 197812504, notification);
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }
}
