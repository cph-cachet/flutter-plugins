package de.kn.uni.smartact.movisenslibrary.screens.viewmodel;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.ContentObserver;
import android.database.Cursor;
import android.net.Uri;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;

import java.util.HashMap;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.bluetooth.MovisensService;
import de.kn.uni.smartact.movisenslibrary.database.MovisensData;
import de.kn.uni.smartact.movisenslibrary.screens.view.Activity_BluetoothData;
import de.kn.uni.smartact.movisenslibrary.screens.view.Activity_BluetoothDeviceScan;
import de.kn.uni.smartact.movisenslibrary.utils.BindableBoolean;
import de.kn.uni.smartact.movisenslibrary.utils.BindableString;

import static de.kn.uni.smartact.movisenslibrary.bluetooth.MovisensService.ALLOWDELETEDATE;
import static de.kn.uni.smartact.movisenslibrary.bluetooth.MovisensService.AUTOSTARTNEWMEASUREMENT;
import static de.kn.uni.smartact.movisenslibrary.bluetooth.MovisensService.TAG;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_AGE;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_BATTERY;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_FIRMWARE;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_GENDER;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_HEIGHT;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_SENSORADDRESS;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_SENSORLOCATION;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_SENSORNAME;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_WEIGHT;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.SENSORDATA_PROJECTION_ALL;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.SENSORDATA_URI;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_LIGHT;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_MET;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_MODERATE;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_STEPS;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_TIMESTAMP;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_UPDATED;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_VIGOROUS;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.TBL_TRACKINDATA;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.TRACKINGDATA_PROJECTION_ALL;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.TRACKINGDATA_URI;


public class Handler_BluetoothStart {

    private final Context mContext;
    private HashMap<String, String> userDataMap;

    public BindableString autoStartNewMeasurement;

    public BindableString sensorname;
    public BindableString firmware;
    public BindableString battery;

    public BindableString timestamp;
    public BindableString steps;
    public BindableString met;
    public BindableString light;
    public BindableString moderate;
    public BindableString vigorous;
    public BindableString created;

    public BindableBoolean isUserInizialised;
    public BindableBoolean isSensorAddressInizialised;

    public BindableBoolean isServiceRunning;
    public BindableBoolean isServiceStartEnabled;



    public Handler_BluetoothStart(Context context, HashMap<String, String> userDataMap) {
        this.userDataMap = userDataMap;
        Log.d("HandlerBluetoothStart", this.userDataMap.toString());
        mContext = context;

        isUserInizialised = new BindableBoolean();
        isSensorAddressInizialised = new BindableBoolean();
        isServiceStartEnabled = new BindableBoolean();
        isServiceRunning = new BindableBoolean();
        updateButtonEnabled();

        autoStartNewMeasurement = new BindableString(String.valueOf(context.getSharedPreferences(TAG, Context.MODE_PRIVATE).getBoolean(AUTOSTARTNEWMEASUREMENT, false)));
        autoStartNewMeasurement.setUpdateListener(new BindableString.StringUpdateListener() {
            @Override
            public void onUpdate(String value) {
                final Boolean new_value = Boolean.valueOf(value);

                if (new_value) {
                    android.app.AlertDialog.Builder alertDialogBuilder = new android.app.AlertDialog.Builder(mContext);
                    alertDialogBuilder.setMessage(mContext.getString(R.string.auto_start_new_measurement));
                    alertDialogBuilder
                            .setCancelable(false)
                            .setPositiveButton(mContext.getString(R.string.yes), new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(mContext);
                                    SharedPreferences.Editor editor = preferences.edit();
                                    editor.putBoolean(AUTOSTARTNEWMEASUREMENT, true);
                                    editor.commit();
                                }
                            })
                            .setNegativeButton(mContext.getString(R.string.no), new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    autoStartNewMeasurement.set(String.valueOf(false));
                                }
                            });
                    android.app.AlertDialog alertDialog = alertDialogBuilder.create();
                    alertDialog.show();
                } else {
                    SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(mContext);
                    SharedPreferences.Editor editor = preferences.edit();
                    editor.putBoolean(AUTOSTARTNEWMEASUREMENT, false);
                    editor.commit();
                }
            }
        });


        sensorname = new BindableString();
        firmware = new BindableString();
        battery = new BindableString();

        timestamp = new BindableString();
        steps = new BindableString();
        met = new BindableString();
        light = new BindableString();
        moderate = new BindableString();
        vigorous = new BindableString();
        created = new BindableString();

        setFeedback(R.string.sampling_stoped);

        updateSensorData();

        context.getContentResolver().registerContentObserver(MovisensData.TrackingData.TRACKINGDATA_URI, true, new MyObserver(new Handler())); //checks data changes in database
        context.getContentResolver().registerContentObserver(SENSORDATA_URI, true, new MyObserver(new Handler()));

        // START NEW SAMPLE
        restartMeasurement();
    }

    public void updateButtonEnabled() {
        updateUserInizialised();
        updateSensorAddressInizialised();
        isServiceRunning.set(MovisensService.isServiceRunning(mContext));

        updateServiceStartEnabled();
    }

    private void updateUserInizialised() {
        ContentResolver resolver = mContext.getContentResolver();
        try (Cursor cursor = resolver.query(SENSORDATA_URI,         // the URI to query
                SENSORDATA_PROJECTION_ALL,                          // the projection to use
                null,                                      // the where clause without the WHERE keyword
                null,                                   // any wildcard substitutions
                null)) {                                   // the sort order without the SORT BY keyword
            if (cursor != null && cursor.getCount() > 0) {
                cursor.moveToFirst();

                if (cursor.isNull(cursor.getColumnIndex(COL_GENDER)) || cursor.isNull(cursor.getColumnIndex(COL_HEIGHT)) || cursor.isNull(cursor.getColumnIndex(COL_WEIGHT)) ||
                        cursor.isNull(cursor.getColumnIndex(COL_AGE)) || cursor.isNull(cursor.getColumnIndex(COL_SENSORLOCATION)))
                    isUserInizialised.set(false);
                else
                    isUserInizialised.set(true);
            }
        }
    }

    private void updateSensorAddressInizialised() {
        ContentResolver resolver = mContext.getContentResolver();
        try (Cursor cursor = resolver.query(SENSORDATA_URI,         // the URI to query
                SENSORDATA_PROJECTION_ALL,                          // the projection to use
                null,                                      // the where clause without the WHERE keyword
                null,                                   // any wildcard substitutions
                null)) {                                   // the sort order without the SORT BY keyword
            if (cursor != null && cursor.getCount() > 0) {
                cursor.moveToFirst();

                if (cursor.isNull(cursor.getColumnIndex(COL_SENSORADDRESS)) || cursor.getString(cursor.getColumnIndex(COL_SENSORADDRESS)).equals(""))
                    isSensorAddressInizialised.set(false);
                else
                    isSensorAddressInizialised.set(true);
            }
        }

        updateServiceStartEnabled();
    }

    public void updateServiceStartEnabled() {
        isServiceStartEnabled.set(isSensorAddressInizialised.get() && !isServiceRunning.get());
    }

    private void setFeedback(int text) {
        //sensorname.set(mContext.getString(text));
        //firmware.set(mContext.getString(text));
        //battery.set(mContext.getString(text));

        timestamp.set(mContext.getString(text));
        steps.set(mContext.getString(text));
        met.set(mContext.getString(text));
        light.set(mContext.getString(text));
        moderate.set(mContext.getString(text));
        vigorous.set(mContext.getString(text));
        created.set(mContext.getString(text));
    }


//    public void editUser() {
//        stopSampling();
//
//        Intent startUpIntent = new Intent(mContext, Activity_BluetoothUser.class);
//        mContext.startActivity(startUpIntent);
//    }

    public void selectDevice() {
        stopSampling();

        Intent startUpIntent = new Intent(mContext, Activity_BluetoothDeviceScan.class);
        mContext.startActivity(startUpIntent);
    }

    public void startSampling() {
        setFeedback(R.string.sampling_waiting);
        isServiceRunning.set(true);
        updateServiceStartEnabled();
        Log.d(TAG, "START SAMPLING CHECK");

        if (!MovisensService.isServiceRunning(mContext)) {
            Log.d(TAG, "STARTED SAMPLING");
            final Intent gattServiceIntent = new Intent(mContext, MovisensService.class);
            gattServiceIntent.putExtra(ALLOWDELETEDATE, false);
            mContext.startService(gattServiceIntent);
        }
    }

    public void stopSampling() {
        setFeedback(R.string.sampling_stoped);
        isServiceRunning.set(false);
        updateServiceStartEnabled();

        if (MovisensService.isServiceRunning(mContext)) {
            Intent msgIntent = new Intent(mContext, MovisensService.class);
            mContext.stopService(msgIntent);
        }
    }

    public void showData() {
        Intent startUpIntent = new Intent(mContext, Activity_BluetoothData.class);
        mContext.startActivity(startUpIntent);
    }

    public void startNewMeasurement() {
        android.app.AlertDialog.Builder alertDialogBuilder = new android.app.AlertDialog.Builder(mContext);
        alertDialogBuilder.setMessage(mContext.getString(R.string.start_new_measurement));
        alertDialogBuilder
                .setCancelable(false)
                .setPositiveButton(mContext.getString(R.string.yes), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        restartMeasurement();
                    }
                })
                .setNegativeButton(mContext.getString(R.string.no), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {

                    }
                });
        android.app.AlertDialog alertDialog = alertDialogBuilder.create();
        alertDialog.show();
    }

    public void restartMeasurement() {
        stopSampling();

        setFeedback(R.string.sampling_waiting);
        isServiceRunning.set(true);
        updateServiceStartEnabled();

        final Intent gattServiceIntent = new Intent(mContext, MovisensService.class);
        gattServiceIntent.putExtra(ALLOWDELETEDATE, true);
        gattServiceIntent.putExtra("user_data", userDataMap);
        mContext.startService(gattServiceIntent);
    }


    private void updateTrackingData() {
        ContentResolver resolver = mContext.getContentResolver();
        try (Cursor cursor = resolver.query(TRACKINGDATA_URI,                                                       // the URI to query
                TRACKINGDATA_PROJECTION_ALL,                                                                        // the projection to use
                COL_TIMESTAMP + " = (SELECT MAX(" + COL_TIMESTAMP + ") FROM " + TBL_TRACKINDATA + ")",     // the where clause without the WHERE keyword
                null,                                                                                   // any wildcard substitutions
                null)) {                                                                                   // the sort order without the SORT BY keyword
            if (cursor != null && cursor.getCount() > 0) {
                cursor.moveToFirst();

                if (!cursor.isNull(cursor.getColumnIndex(COL_TIMESTAMP)))
                    timestamp.set(cursor.getString(cursor.getColumnIndex(COL_TIMESTAMP)));
                if (!cursor.isNull(cursor.getColumnIndex(COL_STEPS)))
                    steps.set(String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_STEPS))));
                if (!cursor.isNull(cursor.getColumnIndex(COL_MET)))
                    met.set(String.valueOf(cursor.getDouble(cursor.getColumnIndex(COL_MET))));
                if (!cursor.isNull(cursor.getColumnIndex(COL_LIGHT)))
                    light.set(String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_LIGHT))));
                if (!cursor.isNull(cursor.getColumnIndex(COL_MODERATE)))
                    moderate.set(String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_MODERATE))));
                if (!cursor.isNull(cursor.getColumnIndex(COL_VIGOROUS)))
                    vigorous.set(String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_VIGOROUS))));
                if (!cursor.isNull(cursor.getColumnIndex(COL_UPDATED)))
                    created.set(cursor.getString(cursor.getColumnIndex(COL_UPDATED)));
            }
        }
    }

    private void updateSensorData() {
        ContentResolver resolver = mContext.getContentResolver();
        try (Cursor cursor = resolver.query(SENSORDATA_URI,         // the URI to query
                SENSORDATA_PROJECTION_ALL,                          // the projection to use
                null,                                      // the where clause without the WHERE keyword
                null,                                   // any wildcard substitutions
                null)) {                                   // the sort order without the SORT BY keyword
            if (cursor != null && cursor.getCount() > 0) {
                cursor.moveToFirst();

                if (!cursor.isNull(cursor.getColumnIndex(COL_SENSORNAME)))
                    sensorname.set(cursor.getString(cursor.getColumnIndex(COL_SENSORNAME)));
                if (!cursor.isNull(cursor.getColumnIndex(COL_FIRMWARE)))
                    firmware.set(cursor.getString(cursor.getColumnIndex(COL_FIRMWARE)));
                if (!cursor.isNull(cursor.getColumnIndex(COL_BATTERY)))
                    battery.set(String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_BATTERY))));
            }
        }
    }

    class MyObserver extends ContentObserver {
        public MyObserver(Handler handler) {
            super(handler);
        }

        @Override
        public void onChange(boolean selfChange) {
            this.onChange(selfChange, null);
        }

        @Override
        public void onChange(boolean selfChange, Uri uri) {
            // depending on the handler you might be on the UI thread, so be cautious!
            if (uri.equals(TRACKINGDATA_URI))
                updateTrackingData();

            if (uri.equals(SENSORDATA_URI))
                updateSensorData();
        }
    }


}
