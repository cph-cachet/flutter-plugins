package de.kn.uni.smartact.movisenslibrary.screens.viewmodel;

import android.app.Activity;
import android.content.ContentResolver;
import android.database.Cursor;

import java.util.ArrayList;
import java.util.List;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.model.BluetoothData;
import de.kn.uni.smartact.movisenslibrary.screens.adapter.BluetoothDataAdapter;

import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_COUNT;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_LIGHT;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_MET;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_MODERATE;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_STEPS;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_TIMESTAMP;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_VIGOROUS;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.TRACKINGDATA_PROJECTION_GROUP_BY_DAY;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.TRACKINGDATA_SELECTION_GROUP_BY_DAY;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.TRACKINGDATA_URI;


public class Handler_BluetoothData {

    Activity mContext;
    BluetoothDataAdapter mAdapter;
    List<BluetoothData> mBluetoothDataList;

    public Handler_BluetoothData(Activity context) {
        mContext = context;

        mBluetoothDataList = new ArrayList<>();

        ContentResolver resolver = context.getContentResolver();
        try (Cursor cursor = resolver.query(TRACKINGDATA_URI,                                                       // the URI to query
                TRACKINGDATA_PROJECTION_GROUP_BY_DAY,                                                                        // the projection to use
                TRACKINGDATA_SELECTION_GROUP_BY_DAY,     // the where clause without the WHERE keyword
                null,                                                                                   // any wildcard substitutions
                null)) {                                                                                   // the sort order without the SORT BY keyword
            if (cursor != null && cursor.getCount() > 0) {
                cursor.moveToFirst();

                while (!cursor.isAfterLast()) {
                    String timestamp = cursor.getString(cursor.getColumnIndex(COL_TIMESTAMP));
                    String steps = String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_STEPS)));
                    String met = String.valueOf(cursor.getDouble(cursor.getColumnIndex(COL_MET)));
                    String light = String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_LIGHT)));
                    String moderate = String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_MODERATE)));
                    String vigorous = String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_VIGOROUS)));
                    String count = String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_COUNT)));

                    mBluetoothDataList.add(new BluetoothData(timestamp, steps, met, light, moderate, vigorous, count));

                    cursor.moveToNext();
                }
            }
        }

    }

    public BluetoothDataAdapter getListAdapter(){
        if (mAdapter == null) {
            mAdapter = new BluetoothDataAdapter(mBluetoothDataList);
        }

        return mAdapter;
    }
}
