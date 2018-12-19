package de.kn.uni.smartact.movisenslibrary.database;

import android.content.ContentResolver;
import android.net.Uri;
import android.provider.BaseColumns;

public class MovisensData {

    public static final String AUTHORITY = "de.kn.uni.smartact.movisenslibrary.database.movisensdata";
    public static final Uri MOVISENSDATA_URI = Uri.parse("content://" + AUTHORITY);


    /**
     * Constants for the BluetoothData table of the MovisensData provider.
     */
    public static final class TrackingData implements CommonColumns {
        public static final String TBL_TRACKINDATA = "trackingdata";

        /**
         * The timestamp
         * <P>Type: DATETIME</P>
         */
        public static final String COL_TIMESTAMP = "timestamp";

        /**
         * The steps
         * <P>Type: INTEGER</P>
         */
        public static final String COL_STEPS = "steps";

        /**
         * The met
         * <P>Type: DOUBLE</P>
         */
        public static final String COL_MET = "met";

        /**
         * The timeLight
         * <P>Type: INTEGER</P>
         */
        public static final String COL_LIGHT = "light";

        /**
         * The timeLight
         * <P>Type: INTEGER</P>
         */
        public static final String COL_MODERATE = "moderate";

        /**
         * The timeLight
         * <P>Type: INTEGER</P>
         */
        public static final String COL_VIGOROUS = "vigorous";

        /**
         * The group by count
         * <P>Type: INTEGER</P>
         */
        public static final String COL_PROCESSED = "processed";

        /**
         * The group by count
         * <P>Type: INTEGER</P>
         */
        public static final String COL_COUNT = "count";


        public static final String DDL_CREATE_TBL_TRACKINGDATA = "CREATE TABLE " + TBL_TRACKINDATA +
                " (" +
                COL_TIMESTAMP   + " DATETIME PRIMARY KEY, " +
                COL_STEPS       + " INTEGER, " +
                COL_MET         + " DOUBLE, " +
                COL_LIGHT       + " INTEGER, " +
                COL_MODERATE    + " INTEGER, " +
                COL_VIGOROUS    + " INTEGER, " +
                COL_UPDATED     + " DATETIME, " +
                COL_PROCESSED   + " TEXT" +
                ")";

        public static final String DDL_DROP_TBL_TRACKINGDATA = "DROP TABLE IF EXISTS " + TBL_TRACKINDATA;



        public static final Uri TRACKINGDATA_URI = Uri.withAppendedPath(MOVISENSDATA_URI, TBL_TRACKINDATA);

        public static final String TRACKINGDATA_DIR_TYPE = ContentResolver.CURSOR_DIR_BASE_TYPE + "/de.kn.uni.smartact.movisenslibrary.movisensdata_trackingdata";
        public static final String TRACKINGDATA_ITEM_TYPE = ContentResolver.CURSOR_ITEM_BASE_TYPE + "/de.kn.uni.smartact.movisenslibrary.movisensdata_trackingdata";

        public static final String[] TRACKINGDATA_PROJECTION_ALL = {COL_TIMESTAMP, COL_STEPS, COL_MET, COL_LIGHT, COL_MODERATE, COL_VIGOROUS, COL_UPDATED};

        public static final String[] TRACKINGDATA_PROJECTION_GROUP_BY_DAY = {"strftime('%Y-%m-%d'," + COL_TIMESTAMP + ") AS " + COL_TIMESTAMP, "SUM("+COL_STEPS+") AS " + COL_STEPS, "SUM("+COL_MET+") AS " +
                COL_MET, "SUM("+COL_LIGHT+") AS " + COL_LIGHT, "SUM("+COL_MODERATE+") AS " + COL_MODERATE, "SUM("+COL_VIGOROUS+") AS " + COL_VIGOROUS, "count(*) AS " + COL_COUNT};
        public static final String TRACKINGDATA_SELECTION_GROUP_BY_DAY = "0 == 0) GROUP BY strftime('%Y-%m-%d', + " + COL_TIMESTAMP;

        public static final String TRACKINGDATA_SORT_ORDER_DEFAULT = COL_TIMESTAMP + " ASC";
    }


    /**
     * Constants for the BluetoothData table of the MovisensData provider.
     */
    public static final class SensorData implements CommonColumns {
        public static final String TBL_SENSORDATA = "sensordata";

        /**
         * The weight
         * <P>Type: INTEGER</P>
         */
        public static final String COL_WEIGHT = "weight";

        /**
         * The height
         * <P>Type: INTEGER</P>
         */
        public static final String COL_HEIGHT = "height";

        /**
         * The gender
         * <P>Type: TEXT</P>
         */
        public static final String COL_GENDER = "gender";

        /**
         * The age
         * <P>Type: INTEGER</P>
         */
        public static final String COL_AGE = "age";

        /**
         * The firmware
         * <P>Type: STRING</P>
         */
        public static final String COL_FIRMWARE = "firmware";

        /**
         * The sensor location
         * <P>Type: STRING</P>
         */
        public static final String COL_SENSORLOCATION = "sensor_location";

        /**
         * The sensor address
         * <P>Type: STRING</P>
         */
        public static final String COL_SENSORADDRESS = "sensor_address";

        /**
         * The sensor name
         * <P>Type: STRING</P>
         */
        public static final String COL_SENSORNAME = "sensor_name";

        /**
         * The battery
         * <P>Type: DOUBLE</P>
         */
        public static final String COL_BATTERY = "battery";

        /**
         * The connection state
         * <P>Type: INTEGER</P>
         */
        public static final String COL_CONNECTED = "connected";


        public static final String DDL_CREATE_TBL_SENSORDATA = "CREATE TABLE " + TBL_SENSORDATA +
                " (" +
                    COL_WEIGHT          + " INTEGER, " +
                    COL_HEIGHT          + " INTEGER, " +
                    COL_GENDER          + " TEXT, " +
                    COL_AGE             + " INTEGER, " +
                    COL_FIRMWARE        + " TEXT, " +
                    COL_SENSORLOCATION  + " TEXT, " +
                    COL_SENSORADDRESS   + " TEXT, " +
                    COL_SENSORNAME      + " TEXT, " +
                    COL_BATTERY         + " DOUBLE, " +
                    COL_CONNECTED       + " INTEGER, " +
                COL_UPDATED         + " DATETIME" +
                ")";

        public static final String DDL_DROP_TBL_SENSORDATA = "DROP TABLE IF EXISTS " + TBL_SENSORDATA;



        public static final Uri SENSORDATA_URI = Uri.withAppendedPath(MOVISENSDATA_URI, TBL_SENSORDATA);

        public static final String SENSORDATA_DIR_TYPE = ContentResolver.CURSOR_DIR_BASE_TYPE + "/de.kn.uni.smartact.movisenslibrary.movisensdata_sensordata";

        public static final String[] SENSORDATA_PROJECTION_ALL = {COL_WEIGHT, COL_HEIGHT, COL_GENDER, COL_AGE, COL_FIRMWARE, COL_SENSORLOCATION, COL_SENSORADDRESS, COL_SENSORNAME, COL_BATTERY, COL_CONNECTED, COL_UPDATED};
        public static final String SENSORDATA_SORT_ORDER_DEFAULT = COL_UPDATED + " ASC";
    }


    /**
     * Constants for the Logging table of the MovisensData provider.
     */
    public static final class LoggingData {
        public static final String TBL_LOGGINGDATA = "loggingdata";

        /**
         * The timestamp
         * <P>Type: DATETIME</P>
         */
        public static final String COL_TIMESTAMP = "timestamp";

        /**
         * The TAG
         * <P>Type: STRING</P>
         */
        public static final String COL_TAG = "tag";

        /**
         * The MESSAGE
         * <P>Type: STRING</P>
         */
        public static final String COL_MESSAGE = "message";


        public static final String DDL_CREATE_TBL_LOGGINGDATA = "CREATE TABLE " + TBL_LOGGINGDATA +
                " (" +
                COL_TIMESTAMP   + " DATETIME, " +
                COL_TAG   + " TEXT, " +
                COL_MESSAGE   + " TEXT" +
                ")";

        public static final String DDL_DROP_TBL_LOGGINGDATA = "DROP TABLE IF EXISTS " + TBL_LOGGINGDATA;



        public static final Uri LOGGINGDATA_URI = Uri.withAppendedPath(MOVISENSDATA_URI, TBL_LOGGINGDATA);

        public static final String LOGGINGDATA_DIR_TYPE = ContentResolver.CURSOR_DIR_BASE_TYPE + "/de.kn.uni.smartact.movisenslibrary.movisensdata_loggingdata";
        public static final String LOGGINGDATA_ITEM_TYPE = ContentResolver.CURSOR_ITEM_BASE_TYPE + "/de.kn.uni.smartact.movisenslibrary.movisensdata_loggingdata";

        public static final String[] LOGGINGDATA_PROJECTION_ALL = {COL_TIMESTAMP, COL_TAG, COL_MESSAGE};

        public static final String LOGGINGDATA_SORT_ORDER_DEFAULT = COL_TIMESTAMP + " ASC";
    }





    public static interface CommonColumns {
        /**
         * The created
         * <P>Type: DATETIME</P>
         */
        public static final String COL_UPDATED = "updated";
    }
}
