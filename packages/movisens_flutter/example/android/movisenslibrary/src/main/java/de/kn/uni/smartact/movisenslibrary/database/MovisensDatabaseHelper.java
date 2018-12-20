package de.kn.uni.smartact.movisenslibrary.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.LoggingData.DDL_CREATE_TBL_LOGGINGDATA;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.*;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.*;

public class MovisensDatabaseHelper extends SQLiteOpenHelper {
    private static final String DATABASE_NAME = "/mnt/sdcard/movisens.db";
    private static final int DATABASE_VERSION = 1;

    public MovisensDatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(DDL_CREATE_TBL_TRACKINGDATA);
        db.execSQL(DDL_CREATE_TBL_SENSORDATA);
        db.execSQL(DDL_CREATE_TBL_LOGGINGDATA);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
    }
}
