package de.kn.uni.smartact.movisenslibrary.model;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;

import com.movisens.movisensgattlib.attributes.EnumSensorLocation;

import java.util.Map;

import de.kn.uni.smartact.movisenslibrary.database.MovisensData;
import de.kn.uni.smartact.movisenslibrary.utils.BindableString;
import de.kn.uni.smartact.movisenslibrary.utils.TimeFormatUtil;

import static android.content.Context.MODE_PRIVATE;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.*;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.*;


/**
 * Created by Daniel on 11/29/16.
 */

public class UserData {
    private static final String DEFAULT_WEIGHT = "80";
    private static final String DEFAULT_HEIGHT = "180";
    private static final String DEFAULT_GENDER = "male";
    private static final String DEFAULT_AGE = "23";

    public BindableString weight;
    public BindableString height;
    public BindableString gender;
    public BindableString age;
    public BindableString sensor_location;
    public BindableString sensor_address;
    public BindableString sensor_name;

    public UserData(Map<String, String> userData) {
        this.weight = new BindableString(userData.get("weight"));
        this.height = new BindableString(userData.get("height"));
        this.gender = new BindableString(userData.get("gender"));
        this.age = new BindableString(userData.get("age"));

        this.sensor_location = new BindableString(userData.get("sensor_location"));
        this.sensor_address = new BindableString(userData.get("sensor_address"));
        this.sensor_name = new BindableString(userData.get("sensor_name"));
    }

    public UserData() {
        this.weight = new BindableString("100");
        this.height = new BindableString("100");
        this.gender = new BindableString("male");
        this.age = new BindableString("100");

        this.sensor_location = new BindableString("CHEST");
        this.sensor_address = new BindableString("88:6B:0F:82:1D:33");
        this.sensor_name = new BindableString("Sensor 02655");
    }


//    public UserData(Context context) {
//        this.weight = new BindableString(DEFAULT_WEIGHT);
//        this.height = new BindableString(DEFAULT_HEIGHT);
//        this.gender = new BindableString(DEFAULT_GENDER);
//        this.age = new BindableString(DEFAULT_AGE);
//
//        this.sensor_location = new BindableString();
//        this.sensor_address = new BindableString();
//        this.sensor_name = new BindableString();
//
//        getFromDB(context);
//    }

    public String toString() {
        return "UserData : {" +
                "weight: " + weight.get() + ", " +
                "height: " + height.get() + ", " +
                "gender: " + gender.get() + ", " +
                "age: " + age.get() +
                "}";
    }

    public EnumSensorLocation getEnumSensorLocation() {
        return sensorLocationByName(sensor_location.get());
    }

    private static EnumSensorLocation sensorLocationByName(String name) {

        EnumSensorLocation location = EnumSensorLocation.CHEST;
        Log.d("Test SensorPosition", name);
        switch (name) {
            case "Brust":
                location = EnumSensorLocation.CHEST;
                break;
            case "Linker Knöchel":
                location = EnumSensorLocation.LEFT_ANKLE;
                break;
            case "Linke Seite Hüfte":
                location = EnumSensorLocation.LEFT_SIDE_HIP;
                break;
            case "Linker Oberschenkel":
                location = EnumSensorLocation.LEFT_THIGH;
                break;
            case "Linker Oberarm":
                location = EnumSensorLocation.LEFT_UPPER_ARM;
                break;
            case "Linkes Handgelenk":
                location = EnumSensorLocation.LEFT_WRIST;
                break;
            case "Rechter Knöchel":
                location = EnumSensorLocation.RIGHT_ANKLE;
                break;
            case "Rechte Seite Hüfte":
                location = EnumSensorLocation.RIGHT_SIDE_HIP;
                break;
            case "Rechter Oberschenkel":
                location = EnumSensorLocation.RIGHT_THIGH;
                break;
            case "Rechter Oberarm":
                location = EnumSensorLocation.RIGHT_UPPER_ARM;
                break;
            case "Rechtes Handgelenk":
                location = EnumSensorLocation.RIGHT_WRIST;
                break;
        }
        return location;
    }

//    public void saveToDB(Context context) {
//        ContentValues values = new ContentValues();
//        values.put(COL_HEIGHT, height.get());
//        values.put(COL_WEIGHT, weight.get());
//        values.put(COL_GENDER, gender.get());
//        values.put(COL_AGE, age.get());
//        values.put(COL_SENSORLOCATION, sensor_location.get());
//        values.put(COL_SENSORADDRESS, sensor_address.get());
//        values.put(COL_SENSORNAME, sensor_name.get());
//        values.put(COL_UPDATED, TimeFormatUtil.getDateString());
//        context.getContentResolver().insert(MovisensData.SensorData.SENSORDATA_URI, values);
//    }
//
//    public void getFromDB(Context context) {
//        ContentResolver resolver = context.getContentResolver();
//        try (Cursor cursor = resolver.query(SENSORDATA_URI,         // the URI to query
//                SENSORDATA_PROJECTION_ALL,                          // the projection to use
//                null,                                      // the where clause without the WHERE keyword
//                null,                                   // any wildcard substitutions
//                null)) {                                   // the sort order without the SORT BY keyword
//            if (cursor != null && cursor.getCount() > 0) {
//                cursor.moveToFirst();
//
//                height.set(String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_HEIGHT))));
//                weight.set(String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_WEIGHT))));
//                gender.set(cursor.getString(cursor.getColumnIndex(COL_GENDER)));
//                age.set(String.valueOf(cursor.getInt(cursor.getColumnIndex(COL_AGE))));
//                sensor_location.set(cursor.getString(cursor.getColumnIndex(COL_SENSORLOCATION)));
//                sensor_address.set(cursor.getString(cursor.getColumnIndex(COL_SENSORADDRESS)));
//                sensor_name.set(cursor.getString(cursor.getColumnIndex(COL_SENSORNAME)));
//            }
//        }
//    }
}