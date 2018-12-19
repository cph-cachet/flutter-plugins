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

}