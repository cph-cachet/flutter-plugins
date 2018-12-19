package de.kn.uni.smartact.movisenslibrary.bluetooth;
import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGattService;
import android.content.BroadcastReceiver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Binder;
import android.os.IBinder;
import android.os.ParcelUuid;
import android.preference.PreferenceManager;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.movisens.movisensgattlib.MovisensCharacteristics;
import com.movisens.movisensgattlib.MovisensServices;
import com.movisens.movisensgattlib.attributes.AgeFloat;
import com.movisens.movisensgattlib.attributes.BatteryLevelBuffered;
import com.movisens.movisensgattlib.attributes.DataAvailable;
import com.movisens.movisensgattlib.attributes.EnumSensorLocation;
import com.movisens.movisensgattlib.attributes.MeasurementEnabled;
import com.movisens.movisensgattlib.attributes.MetBuffered;
import com.movisens.movisensgattlib.attributes.MetLevelBuffered;
import com.movisens.movisensgattlib.attributes.SensorLocation;
import com.movisens.movisensgattlib.attributes.StepsBuffered;
import com.movisens.movisensgattlib.attributes.TapMarker;
import com.movisens.smartgattlib.Characteristics;
import com.movisens.smartgattlib.Services;
import com.movisens.smartgattlib.attributes.EnumGender;
import com.movisens.smartgattlib.attributes.FirmwareRevisionString;
import com.movisens.smartgattlib.attributes.Gender;
import com.movisens.smartgattlib.attributes.Height;
import com.movisens.smartgattlib.attributes.Weight;
import com.movisens.smartgattlib.helper.GattByteBuffer;

import org.joda.time.DateTime;

import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.SensorApplication;
import de.kn.uni.smartact.movisenslibrary.database.MovisensData;
import de.kn.uni.smartact.movisenslibrary.events.MeasurementStatus;
import de.kn.uni.smartact.movisenslibrary.model.UserData;
import de.kn.uni.smartact.movisenslibrary.screens.NoMeasurmentDialog;
import de.kn.uni.smartact.movisenslibrary.utils.BleUtils;
import de.kn.uni.smartact.movisenslibrary.utils.TimeFormatUtil;

import static de.kn.uni.smartact.movisenslibrary.bluetooth.BLEConnectionHandler.ACTION_LOG;
import static de.kn.uni.smartact.movisenslibrary.bluetooth.BLEConnectionHandler.EXTRA_MESSAGE;
import static de.kn.uni.smartact.movisenslibrary.bluetooth.BLEConnectionHandler.EXTRA_TAG;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.LoggingData.COL_MESSAGE;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.LoggingData.COL_TAG;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_BATTERY;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_CONNECTED;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_FIRMWARE;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.COL_UPDATED;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_LIGHT;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_MET;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_MODERATE;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_STEPS;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.COL_VIGOROUS;

public class MovisensService extends Service {

    public final static String TAG = MovisensService.class.getSimpleName();
    public final static String ALLOWDELETEDATE = "allowdeletedata";
    public final static String AUTOSTARTNEWMEASUREMENT = "autostartnewmeasurement";

    public final static String MOVISENS_INTENT_NAME = "movisens_events";
    public final static String MOVISENS_BATTERY_LEVEL = "battery_level";
    public final static String MOVISENS_TAP_MARKER = "tap_marker";
    public final static String MOVISENS_STEP_COUNT = "step_count";
    public final static String MOVISENS_MET_LEVEL = "met_level";


    private final static int NOTIFICATION_ID = 1377;
    private final static int IDLE_CHECK_INTERVAL = 30000;
    private final static int IDLE_RECONNECT_INTERVAL = 180000;


    private boolean allow_delete_data = false;
    private long timeLastReceived;
    private MeasurementStatus measurementStatus = new MeasurementStatus();
    private MovisensService.StateMachine dataReceiverSM;
    private BLEConnectionHandler connectionHandler;
    private String deviceAdress;
    private ScheduledThreadPoolExecutor mScheduler;
    private UserData userData;

    public void broadcastData(String key, String value) {
//        Log.d("MovisensService", "broadcastData()");
        Intent dataIntent = new Intent(MOVISENS_INTENT_NAME);
        dataIntent.putExtra(key, value);
        sendBroadcast(dataIntent);
    }

    public static boolean isServiceRunning(Context context) {
        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (MovisensService.class.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }

    private final IBinder mBinder = new MovisensService.LocalBinder();

    public class LocalBinder extends Binder {
        public MovisensService getService() {
            return MovisensService.this;
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        mScheduler = (ScheduledThreadPoolExecutor) Executors.newScheduledThreadPool(1);

        startForeground(NOTIFICATION_ID, getNotification(R.string.notification_title, R.string.sensor_disconnected, R.drawable.ic_stat_disconnected));

        log(TAG, "Create Service");
    }

    public Notification getNotification(int title, int text, int icon) {
        NotificationCompat.Builder foregroundNotification = new NotificationCompat.Builder(this);
        foregroundNotification.setOngoing(true);

        foregroundNotification.setContentTitle(getText(title))
                .setContentText(getText(text))
                .setSmallIcon(icon);

        return foregroundNotification.build();
    }

    private void updateNotification(int title, int text, int icon) {
        Notification notification = getNotification(title, text, icon);

        NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.notify(NOTIFICATION_ID, notification);
    }

    private void removeNotification() {
        NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.cancel(NOTIFICATION_ID);
    }

    private void setConnectionState(Boolean connected) {
        if (connected) {
            updateNotification(R.string.notification_title, R.string.sensor_connected, R.drawable.ic_stat_connected);
        } else {
            updateNotification(R.string.notification_title, R.string.sensor_disconnected, R.drawable.ic_stat_disconnected);
        }

        ContentValues values = new ContentValues();
        values.put(COL_CONNECTED, connected);
        values.put(COL_UPDATED, TimeFormatUtil.getDateString());
        getContentResolver().insert(MovisensData.SensorData.SENSORDATA_URI, values);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);

        allow_delete_data = intent.getBooleanExtra(ALLOWDELETEDATE, false);
        HashMap<String, String> userDataMap = (HashMap<String, String>) intent.getSerializableExtra("user_data");
        userData = new UserData(userDataMap);

        start();
        log(TAG, "Service stared");
        return Service.START_NOT_STICKY;
    }


    @Override
    public void onDestroy() {
        stop();

        log(TAG, "Service stoped and destroyed");
        removeNotification();
        super.onDestroy();
    }

    public void start() {
        if (connectionHandler != null)
            stop();

        Log.d(TAG, "Starting Gatt service");

        timeLastReceived = new Date().getTime();

        dataReceiverSM = new MovisensService.StateMachine(this);

        connectionHandler = new BLEConnectionHandler(this);
        if (connectionHandler.initialize()) {
//            deviceAdress = (new UserData()).sensor_address.get();
            deviceAdress = userData.sensor_address.get();
            String sensorname = connectionHandler.setDevice(deviceAdress);
        } else {
            setConnectionState(false);
        }

        registerReceivers();
        mScheduler.scheduleAtFixedRate(
                new Runnable() {
                    @Override
                    public void run() {
                        if ((new Date().getTime() - timeLastReceived) > IDLE_RECONNECT_INTERVAL) {
                            setConnectionState(false);
                            timeLastReceived = new Date().getTime();
                            Log.d("DISCONNECT", "Idle timer: " + IDLE_RECONNECT_INTERVAL);
                            connectionHandler.reconnectDelayed();
                        }
                    }
                }
                , 0, IDLE_CHECK_INTERVAL, TimeUnit.MILLISECONDS);
    }

    public void stop() {
        setConnectionState(false);
        mScheduler.shutdownNow();

        if (connectionHandler != null) {
            Log.d(TAG, "Stopping Gatt service");

            connectionHandler.close();
            connectionHandler = null;
            dataReceiverSM = null;
            unRegisterReceivers();
        } else {
            Log.d(TAG, "GATT service not running");
        }

        stopForeground(true);
    }

    private void unRegisterReceivers() {
        try {
            unregisterReceiver(mGattUpdateReceiver);
        } catch (Exception exp) {
            exp.printStackTrace();
        }

        try {
            unregisterReceiver(mBlueToothReceiver);
        } catch (Exception exp) {
            exp.printStackTrace();
        }
    }

    private void registerReceivers() {
        registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter());

        final IntentFilter filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
        registerReceiver(mBlueToothReceiver, filter);
    }

    private static IntentFilter makeGattUpdateIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(BLEConnectionHandler.ACTION_GATT_CONNECTED);
        intentFilter.addAction(BLEConnectionHandler.ACTION_GATT_DISCONNECTED);
        intentFilter.addAction(BLEConnectionHandler.ACTION_GATT_SERVICES_DISCOVERED);
        intentFilter.addAction(BLEConnectionHandler.ACTION_DATA_AVAILABLE);
        intentFilter.addAction(BLEConnectionHandler.ACTION_GATT_SERVICES_ERROR);
        intentFilter.addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED);
        intentFilter.addAction(ACTION_LOG);
        return intentFilter;
    }

    // Handles various events fired by the Service.
    // ACTION_GATT_CONNECTED: connected to a GATT server.
    // ACTION_GATT_DISCONNECTED: disconnected from a GATT server.
    // ACTION_GATT_SERVICES_DISCOVERED: discovered GATT services.
    // ACTION_DATA_AVAILABLE: received data from the device. This can be a
    // result of read
    // or notification operations.
    private final BroadcastReceiver mGattUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();

            timeLastReceived = new Date().getTime();

            if (BLEConnectionHandler.ACTION_GATT_CONNECTED.equals(action)) {
                setConnectionState(true);

                log(TAG, "BLE: GATT Connected");
            } else if (BLEConnectionHandler.ACTION_GATT_DISCONNECTED.equals(action)) {
                connectionHandler.close();
                connectionHandler.reconnectDelayed();
                setConnectionState(false);

                log(TAG, "BLE: GATT Disconnected");
            } else if (BLEConnectionHandler.ACTION_GATT_SERVICES_DISCOVERED.equals(action)) {
                checkMeasurementStatus();

                log(TAG, "BLE: Gatt services discovered");
            } else if (BLEConnectionHandler.ACTION_DATA_AVAILABLE.equals(action)) {
                final byte[] data = intent.getByteArrayExtra(BLEConnectionHandler.EXTRA_DATA);
                ParcelUuid uuidExtra = intent.getParcelableExtra(BLEConnectionHandler.EXTRA_CHARACTERISTIC);
                UUID uuid = uuidExtra.getUuid();

                dataReceiverSM.state.receiveData(dataReceiverSM, data, uuid);

            } else if (BLEConnectionHandler.ACTION_GATT_SERVICES_ERROR.equals(action)) {
                connectionHandler.reconnectDelayed();
                setConnectionState(false);

                log(TAG, "BLE: Gatt services error");
            } else if (BluetoothDevice.ACTION_BOND_STATE_CHANGED.equals(action)) {
                log(TAG, "BLE: Bond state changed");
            } else if (ACTION_LOG.equals(action)) {
                String tag = intent.getStringExtra(EXTRA_TAG);
                String message = intent.getStringExtra(EXTRA_MESSAGE);
                log(tag, message);
            }
        }
    };

    private final BroadcastReceiver mBlueToothReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();
            if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
                final int state = intent.getIntExtra(
                        BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR);
                switch (state) {
                    case BluetoothAdapter.STATE_ON:
                        setConnectionState(false);
                        registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter());
                        connectionHandler.reconnectDelayed();

                        log(TAG, "BLE: Bluetooth turned on");
                        break;
                    case BluetoothAdapter.STATE_OFF:
                        setConnectionState(false);

                        try {
                            unregisterReceiver(mGattUpdateReceiver);
                        } catch (Exception exp) {
                            exp.printStackTrace();
                        }

                        //reactivate bluetooth
                        connectionHandler.setBluetooth(true);

                        log(TAG, "BLE: Bluetooth turned off");
                        break;
                }
            }
        }
    };

    private void checkMeasurementStatus() {
        dataReceiverSM.reset();
        final List<BluetoothGattService> gattServices = connectionHandler.getSupportedGattServices();

        BluetoothGattService gattService = BleUtils.findService(MovisensServices.SENSOR_CONTROL.getUuid(), gattServices);
        if (gattService != null) {
            BleUtils.readCharacteristic(
                    MovisensCharacteristics.MEASUREMENT_ENABLED.getUuid(), "MEASUREMENT_ENABLED",
                    gattService.getCharacteristics(), connectionHandler);
            BleUtils.readCharacteristic(MovisensCharacteristics.DATA_AVAILABLE.getUuid(), "DATA_AVAILABLE",
                    gattService.getCharacteristics(), connectionHandler);
        } else {
            log(TAG, "GattService not found");
        }
    }

    private void startMeasurement() {
        log(TAG, "Starting Measurmente... ");
        final List<BluetoothGattService> gattServices = connectionHandler.getSupportedGattServices();
        double weight = Double.parseDouble(userData.weight.get());
        double height = Double.parseDouble(userData.height.get()) / 100;

        EnumGender sex = EnumGender.MALE;
        if (userData.gender.get().equals("male")) {
            sex = EnumGender.MALE;
        } else if (userData.gender.get().equals("female")) {
            sex = EnumGender.FEMALE;
        }
        double age = Double.parseDouble(userData.age.get());

        EnumSensorLocation sensorLocation = userData.getEnumSensorLocation();

        //USER_DATA_SERVICE
        BluetoothGattService userDataService = BleUtils.findService(Services.USER_DATA.getUuid(), gattServices);
        if (userDataService != null) {
            BleUtils.writeCharacteristic(
                    Characteristics.WEIGHT.getUuid(), "WEIGHT",
                    userDataService.getCharacteristics(), connectionHandler, new Weight(weight).getBytes());
            BleUtils.writeCharacteristic(
                    Characteristics.HEIGHT.getUuid(), "HEIGHT",
                    userDataService.getCharacteristics(), connectionHandler, new Height(height).getBytes());
            BleUtils.writeCharacteristic(
                    Characteristics.GENDER.getUuid(), "GENDER",
                    userDataService.getCharacteristics(), connectionHandler, new Gender(sex).getBytes());
        }

        // BATTERY_SERVICE Indication
        BluetoothGattService batteryService = BleUtils.findService(MovisensServices.MOVISENS_BATTERY.getUuid(), gattServices);
        Log.d("battery_uuid ", MovisensServices.MOVISENS_BATTERY.getUuid().toString());

        if (batteryService != null) {
            BleUtils.enableCharacteristicIndication(MovisensCharacteristics.BATTERY_LEVEL_BUFFERED.getUuid(), "BATTERY_LEVEL_BUFFERED",
                    batteryService.getCharacteristics(), connectionHandler);
        }


        // DeviceInformationService
        BluetoothGattService deviceService = BleUtils.findService(Services.DEVICE_INFORMATION.getUuid(), gattServices);
        if (deviceService != null) {
            BleUtils.readCharacteristic(Characteristics.FIRMWARE_REVISION_STRING.getUuid(), "FIRMWARE_REVISION_STRING",
                    deviceService.getCharacteristics(), connectionHandler);
        }

        // ACC_SERVICE Indication
        BluetoothGattService accService = BleUtils.findService(MovisensServices.PHYSICAL_ACTIVITY.getUuid(), gattServices);
        if (accService != null) {
            BleUtils.enableCharacteristicIndication(
                    MovisensCharacteristics.MET_BUFFERED.getUuid(), "MET_BUFFERED",
                    accService.getCharacteristics(), connectionHandler);
            BleUtils.enableCharacteristicIndication(
                    MovisensCharacteristics.STEPS_BUFFERED.getUuid(), "STEP_COUNT_BUFFERED",
                    accService.getCharacteristics(), connectionHandler);
            BleUtils.enableCharacteristicIndication(
                    MovisensCharacteristics.MET_LEVEL_BUFFERED.getUuid(), "MET_LEVEL_BUFFERED",
                    accService.getCharacteristics(), connectionHandler);
        }


        BluetoothGattService markerService = BleUtils.findService(MovisensServices.MARKER.getUuid(), gattServices);
        Log.d("marker_uuid ", markerService.getUuid().toString());


        if (markerService != null) {

            Log.d("marker", markerService.getCharacteristics().get(0).getUuid().toString());
            BleUtils.enableCharacteristicNotification(
                    MovisensCharacteristics.TAP_MARKER.getUuid(), "TAP_MARKER",
                    markerService.getCharacteristics(), connectionHandler);
        }


        // MOVISENS_SERVICE
        BluetoothGattService movisensService = BleUtils.findService(MovisensServices.MOVISENS_USER_DATA.getUuid(), gattServices);
        if (movisensService != null) {


            BleUtils.writeCharacteristic(
                    MovisensCharacteristics.AGE_FLOAT.getUuid(), "AGE_FLOAT",
                    movisensService.getCharacteristics(), connectionHandler, new AgeFloat(age).getBytes());
            BleUtils.writeCharacteristic(
                    MovisensCharacteristics.SENSOR_LOCATION.getUuid(), "SENSOR_LOCATION",
                    movisensService.getCharacteristics(), connectionHandler, new SensorLocation(sensorLocation).getBytes());
        }


        // MOVISENS_SensorControl
        BluetoothGattService movisensSensorControl = BleUtils.findService(MovisensServices.SENSOR_CONTROL.getUuid(), gattServices);
        if (movisensSensorControl != null) {
            BleUtils.writeCharacteristic(
                    MovisensCharacteristics.CURRENT_TIME.getUuid(), "CURRENT_TIME",
                    movisensSensorControl.getCharacteristics(), connectionHandler, getLocalTime());

            byte[] enable = GattByteBuffer.allocate(1).putBoolean(true).array();

            SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
            Boolean autoStartNewMeasurement = preferences.getBoolean(AUTOSTARTNEWMEASUREMENT, false);

            if (allow_delete_data || autoStartNewMeasurement) {
                BleUtils.writeCharacteristic(
                        MovisensCharacteristics.DELETE_DATA.getUuid(), "DELETE_DATA",
                        movisensSensorControl.getCharacteristics(), connectionHandler, enable);

                BleUtils.enableCharacteristicNotification(
                        MovisensCharacteristics.DELETE_DATA.getUuid(), "DELETE_DATA",
                        movisensSensorControl.getCharacteristics(), connectionHandler);
            }

            BleUtils.writeCharacteristic(
                    MovisensCharacteristics.MEASUREMENT_ENABLED.getUuid(), "MEASUREMENT_ENABLED",
                    movisensSensorControl.getCharacteristics(), connectionHandler, enable);

            BleUtils.enableCharacteristicNotification(
                    MovisensCharacteristics.MEASUREMENT_ENABLED.getUuid(), "MEASUREMENT_ENABLED",
                    movisensSensorControl.getCharacteristics(), connectionHandler);

            BleUtils.writeCharacteristic(
                    MovisensCharacteristics.SAVE_ENERGY.getUuid(), "SAVE_ENERGY",
                    movisensSensorControl.getCharacteristics(), connectionHandler, enable);
        }
    }

    private byte[] getLocalTime() {
        long time = new Date().getTime();
        while ((time % 1000) > 5) {
            time = new Date().getTime();
        }
        GattByteBuffer timeBB = GattByteBuffer.allocate(4);
        return timeBB.putUint32(time / 1000).array();
    }



    // The StateMachine class
    public static class StateMachine {
        MovisensService context;
        MovisensService.StateMachine.State state;

        StateMachine(MovisensService context) {
            this.context = context;
            reset();
        }

        interface State {
            void receiveData(MovisensService.StateMachine sm, final byte[] data, UUID uuid);
        }

        public void reset() {
            state = MovisensService.StateMachine.States.WAIT_FOR_MEASUREMENT_ENABLED; // default
        }

        enum States implements MovisensService.StateMachine.State {
            WAIT_FOR_MEASUREMENT_ENABLED {
                public void receiveData(MovisensService.StateMachine sm, final byte[] data, UUID uuid) {
                    sm.context.log(TAG, "Received data from characteristic Measurement: " + uuid.toString() + ", data: " + BleUtils.bytesToHex(data));

                    if (MovisensCharacteristics.MEASUREMENT_ENABLED.equals(uuid)) {
                        MeasurementEnabled measurementEnabled = new MeasurementEnabled(data);
                        sm.context.measurementStatus.measurementEnabled = measurementEnabled.getMeasurementEnabled() ? MeasurementStatus.SensorState.True : MeasurementStatus.SensorState.False;
                        sm.state = WAIT_FOR_DATA_AVAILABLE;
                    }
                }
            },
            WAIT_FOR_DATA_AVAILABLE {
                public void receiveData(MovisensService.StateMachine sm, final byte[] data, UUID uuid) {
                    sm.context.log(TAG, "Received data from characteristic WAITING: " + uuid.toString() + ", data: " + BleUtils.bytesToHex(data));

                    DataAvailable dataAvailable = new DataAvailable(data);
                    MeasurementStatus measurementStatus = sm.context.measurementStatus;
                    measurementStatus.dataAvailable = dataAvailable.getDataAvailable() ? MeasurementStatus.SensorState.True : MeasurementStatus.SensorState.False;

                    //if allow_delete_data is true start new measurement even if data available --- DATA ON SENSOR WILL BE DELETED
                    SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(sm.context);
                    Boolean autoStartNewMeasurement = preferences.getBoolean(AUTOSTARTNEWMEASUREMENT, false);

                    if (measurementStatus.measurementEnabled == MeasurementStatus.SensorState.True || measurementStatus.dataAvailable == MeasurementStatus.SensorState.False || sm.context.allow_delete_data || autoStartNewMeasurement) {
                        sm.state = RUNNING;
                        sm.context.startMeasurement();

                        sm.context.log(TAG, "New Measurement started");

                        if (measurementStatus.dataAvailable == MeasurementStatus.SensorState.True)
                            sm.context.log(TAG, "Data on Sensor deleted");
                    } else {
                        Intent startUpIntent = new Intent(sm.context, NoMeasurmentDialog.class);
                        sm.context.startActivity(startUpIntent);

                        sm.context.log(TAG, "New Measurement start not possible");
                    }
                }
            },
            RUNNING {
                public void receiveData(MovisensService.StateMachine sm, final byte[] data, UUID uuid) {
                    sm.context.log(TAG, "Received data from characteristic: " + uuid.toString() + ", data: " + BleUtils.bytesToHex(data));
                    /// TAPS!!!
                    if (MovisensCharacteristics.TAP_MARKER.equals(uuid)) {
                        TapMarker marker = new TapMarker(data);
//                        String markerData = "TAP MARKER: " + marker.getTapMarker();
                        String markerData = "" + Calendar.getInstance().getTimeInMillis();
                        sm.context.broadcastData(sm.context.MOVISENS_TAP_MARKER, markerData);
                    }

                    if (MovisensCharacteristics.BATTERY_LEVEL_BUFFERED.equals(uuid)) {
                        BatteryLevelBuffered battery = new BatteryLevelBuffered(data);
                        sm.context.splitAndSaveLastBatteryLevel(battery);
                        String level = "" + battery.getLevel()[0];
                        Log.d(TAG, "BATTERY: " + level);
                        sm.context.broadcastData(sm.context.MOVISENS_BATTERY_LEVEL, level);
                    }

                    if (Characteristics.FIRMWARE_REVISION_STRING.equals(uuid)) {
                        FirmwareRevisionString firmware = new FirmwareRevisionString(data);

                        ContentValues values = new ContentValues();
                        values.put(COL_FIRMWARE, firmware.getFirmware_Revision());
                        sm.context.getContentResolver().insert(MovisensData.SensorData.SENSORDATA_URI, values);
                    }

                    if (MovisensCharacteristics.MEASUREMENT_ENABLED.equals(uuid)) {
                        MeasurementEnabled measurementEnabled = new MeasurementEnabled(data);
                        sm.context.log(TAG, "MeasurementEnabled: " + measurementEnabled.getMeasurementEnabled());
                    }

                    if (MovisensCharacteristics.STEPS_BUFFERED.equals(uuid)) {
                        StepsBuffered stepsBuffered = new StepsBuffered(data);
                        for (Integer stepCount : stepsBuffered.getSteps()) {
                            String stepString = stepCount.toString();
                            Log.d("step", stepString);
                            sm.context.splitAndSaveSteps(stepsBuffered);
                            sm.context.broadcastData(sm.context.MOVISENS_STEP_COUNT, stepString);
                        }
                    }

                    if (MovisensCharacteristics.MET_LEVEL_BUFFERED.equals(uuid)) {
                        MetLevelBuffered new_data = new MetLevelBuffered(data);
                        sm.context.splitAndSaveMetLevel(new_data);
                    }

                    if (MovisensCharacteristics.MET_BUFFERED.equals(uuid)) {
                        MetBuffered new_data = new MetBuffered(data);
                        sm.context.splitAndSaveMet(new_data);
                    }

                    if (MovisensCharacteristics.DATA_AVAILABLE.equals(uuid)) {
                        sm.context.log(TAG, "Data available");
                    }
                }
            }
        }
    }


    /**
     * Function to seperate Timestamp from the string and additionally save it into the current
     * sensor data
     *
     * @param stepsBuffered StepsBuffered class from the sensor
     */
    private void splitAndSaveSteps(StepsBuffered stepsBuffered) {
        String[] splits = stepsBuffered.toString().split("[\\r\\n]+");

        for (int i = 0; i < splits.length; i++) {
            DateTime timestamp = new DateTime((stepsBuffered.getTime().getTime() / 1000 + (long) (1 / stepsBuffered.getSamplerate() * i)) * 1000);
            int steps = stepsBuffered.getSteps()[i];

            ContentValues values = new ContentValues();
            values.put(MovisensData.TrackingData.COL_TIMESTAMP, TimeFormatUtil.getStringFromDate(timestamp));
            values.put(COL_STEPS, steps);
            values.put(COL_UPDATED, TimeFormatUtil.getDateString());
            Uri uri = getContentResolver().insert(MovisensData.TrackingData.TRACKINGDATA_URI, values);

            log("UpdateSensorData", "Time: " + TimeFormatUtil.getStringFromDate(timestamp) + " " + "Steps: " + stepsBuffered.getSteps()[i]);
        }
    }

    /**
     * Function to seperate Timestamp from the string and additionally save it into the current
     * sensor data
     *
     * @param metLevelBuffered MetLevelBuffered class from sensor
     */
    private void splitAndSaveMetLevel(MetLevelBuffered metLevelBuffered) {
        String[] splits = metLevelBuffered.toString().split("[\\r\\n]+");

        for (int i = 0; i < splits.length; i++) {
            DateTime timestamp = new DateTime((metLevelBuffered.getTime().getTime() / 1000 + (long) (1 / metLevelBuffered.getSamplerate() * i)) * 1000);
            Short light = metLevelBuffered.getLight()[i];
            Short vigorous = metLevelBuffered.getVigorous()[i];
            Short moderate = metLevelBuffered.getModerate()[i];

            ContentValues values = new ContentValues();
            values.put(MovisensData.TrackingData.COL_TIMESTAMP, TimeFormatUtil.getStringFromDate(timestamp));
            values.put(COL_LIGHT, light);
            values.put(COL_MODERATE, moderate);
            values.put(COL_VIGOROUS, vigorous);
            values.put(COL_UPDATED, TimeFormatUtil.getDateString());
            Uri uri = getContentResolver().insert(MovisensData.TrackingData.TRACKINGDATA_URI, values);

            log("UpdateSensorData", "Time: " + TimeFormatUtil.getStringFromDate(timestamp) + " Light: " + light + " Vigorous: " + vigorous + " Moderate: " + moderate);
        }
    }

    /**
     * Function to seperate Timestamp from the string and additionally save it into the current
     * sensor data
     *
     * @param metBuffered MetBuffered class from the sensor
     */
    private void splitAndSaveMet(MetBuffered metBuffered) {
        Double[] metValues = metBuffered.getMet();

        for (int i = 0; i < metValues.length; i++) {
            DateTime timestamp = new DateTime((metBuffered.getTime().getTime() / 1000 + (long) (1 / metBuffered.getSamplerate() * i)) * 1000);
            Double met = metBuffered.getMet()[i];

            ContentValues values = new ContentValues();
            values.put(MovisensData.TrackingData.COL_TIMESTAMP, TimeFormatUtil.getStringFromDate(timestamp));
            values.put(COL_MET, met);
            values.put(COL_UPDATED, TimeFormatUtil.getDateString());
            Uri uri = getContentResolver().insert(MovisensData.TrackingData.TRACKINGDATA_URI, values);

            log("UpdateSensorData", "Time: " + TimeFormatUtil.getStringFromDate(timestamp) + " " + "Met: " + metBuffered.getMet()[i]);
        }
    }

    /**
     * Function to get last battery level and additionally save it into the current
     * sensor data
     *
     * @param batteryBuffered BatteryLevelBuffered class from the sensor
     */
    private void splitAndSaveLastBatteryLevel(BatteryLevelBuffered batteryBuffered) {
        Double[] batteryValues = batteryBuffered.getLevel();

        ContentValues values = new ContentValues();
        values.put(COL_BATTERY, batteryValues[0]);
        values.put(COL_UPDATED, TimeFormatUtil.getDateString());
        getContentResolver().insert(MovisensData.SensorData.SENSORDATA_URI, values);

        for (Double value : batteryValues) {
            log(TAG, "Battery: " + value);
        }
    }


    public void log(String tag, String message) {
        if (SensorApplication.DEBUG) {
            ContentValues values = new ContentValues();
            values.put(MovisensData.LoggingData.COL_TIMESTAMP, TimeFormatUtil.getDateString());
            values.put(COL_TAG, tag);
            values.put(COL_MESSAGE, message);
            getContentResolver().insert(MovisensData.LoggingData.LOGGINGDATA_URI, values);
        }

        Log.i(tag, message);
    }
}
