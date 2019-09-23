package io.esense.esenselib;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.util.Log;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * This class provides access to the eSense actions. Fundamentally, this is your starting point for all eSense actions.
 * Once you have the manager instance, you can connect to eSense with {@link #connect(int)}, disconnect from eSense with {@link #disconnect()}, register an event listener with {@link #registerEventListener(ESenseEventListener)}, etc.
 * </p>
 *
 * <p>
 *     See also {@link ESenseScanner}, {@link ESenseConnectionListener}, {@link ESenseEventListener}
 * </p>
 */
public class ESenseManager {
    private final String TAG = "ESenseManager";

    private String mDeviceName;
    private ESenseConnectionListener mConnectionListener;
    private ESenseEventListener mEventListener;
    private ESenseSensorListener mSensorListener;
    private BluetoothDevice mDevice;
    private BluetoothManager mBluetoothManager;
    private ESenseBGattCallback mGattCallback;
    private Map<String, BluetoothGattCharacteristic> mCharacteristicMap;
    private BluetoothGatt mGatt;
    private Context mContext;

    private final String CONFIG_CHARACTERISTIC = "0000ff07-0000-1000-8000-00805f9b34fb";
    private final String SENSOR_CHARACTERISTIC = "0000ff08-0000-1000-8000-00805f9b34fb";
    private final String BUTTON_CHARACTERISTIC = "0000ff09-0000-1000-8000-00805f9b34fb";
    private final String BATTERY_CHARACTERISTIC = "0000ff0a-0000-1000-8000-00805f9b34fb";
    private final String ADV_CONN_CHARACTERISTIC = "0000ff0b-0000-1000-8000-00805f9b34fb";
    private final String NAME_WRITE_CHARACTERISTIC = "0000ff0c-0000-1000-8000-00805f9b34fb";
    private final String DEVICE_NAME_CHARACTERISTIC = "00002a00-0000-1000-8000-00805f9b34fb";
    private final String SENSOR_CONFIG_CHARACTERISTIC = "0000ff0e-0000-1000-8000-00805f9b34fb";
    private final String ACCELEROMETER_OFFSET_CHARACTERISTIC = "0000ff0d-0000-1000-8000-00805f9b34fb";
    private final UUID NOTIFICATION_DESCRIPTOR = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

    /**
     * Constructs an eSense manager for a given device
     * @param deviceName name of the eSense device to look for during a scan
     * @param context application environment to access Bluetooth/BLE interface
     */
    public ESenseManager(String deviceName, Context context) {
        mDeviceName = deviceName;
        mContext = context;
        mGattCallback = new ESenseBGattCallback();
        mBluetoothManager = (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
        mCharacteristicMap = new HashMap<>();
    }

    /**
     * Constructs an eSense manager for a given device with the connection listener
     * @param deviceName name of the eSense device to look for during a scan
     * @param context application environment to access Bluetooth interface
     * @param listener connection listener
     */
    public ESenseManager(String deviceName, Context context, ESenseConnectionListener listener){
        this(deviceName, context);

        if(listener != null)
            mConnectionListener = listener;
    }

    /**
     * Calculates the checksum of the bytes from position (checkSumIndex + 1) until the end of the array
     * @param bytes array of bytes
     * @param checkSumIndex index where checksum will be placed. Checksum computation starts from next byte
     * @return value of checksum
     */
    private byte getCheckSum(byte[] bytes, int checkSumIndex){
        int length = bytes.length;
        int sum = 0;
        for(int i = checkSumIndex + 1 ; i < length ; i++){
            sum += bytes[i] & 0xff;
        }

        return (byte)(sum % 256);
    }

    /**
     * Checks the checksum at the given index from position (checkSumIndex + 1) until the end of the array
     * @param bytes array of bytes
     * @param checkSumIndex index of checksum
     * @return <code>true</code> if the value of checksum is correct,
     *         <code>false</code> otherwise
     */
    private boolean checkCheckSum(byte[] bytes, int checkSumIndex){
        return getCheckSum(bytes, checkSumIndex) == bytes[checkSumIndex];
    }

    /**
     * Initiates a characteristic read on the connected device
     * @param charName name of the characteristic to read
     * @return <code>true</code> if the read operation has been successfully initiated,
     *         <code>false</code> otherwise
     */
    private boolean readCharacteristic(String charName){
        if(isConnected() && !mCharacteristicMap.isEmpty()) {
            BluetoothGattCharacteristic c = mCharacteristicMap.get(charName);
            return mGatt.readCharacteristic(c);
        }

        return false;
    }

    /**
     * Enables or disables notifications on the given characteristic
     * @param characteristic_uuid Characteristic's UUID
     * @param enable <code>true</code> to enable notifications,
     *               <code>false</code> to disable notifications
     */
    private void enableNotification(String characteristic_uuid, boolean enable){
        BluetoothGattCharacteristic characteristic = mCharacteristicMap.get(characteristic_uuid);
        boolean registered = mGatt.setCharacteristicNotification(characteristic, enable);
        if (registered) {
            BluetoothGattDescriptor descriptor = characteristic.getDescriptor(NOTIFICATION_DESCRIPTOR);
            descriptor.setValue(enable ? BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE : BluetoothGattDescriptor.DISABLE_NOTIFICATION_VALUE);
            mGatt.writeDescriptor(descriptor);
        }
    }

    /**
     * Requests a read of the device name.
     * The event {@link ESenseEventListener#onDeviceNameRead(String)} is fired when the name has been read from the connected device.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public boolean getDeviceName() {
        return readCharacteristic(DEVICE_NAME_CHARACTERISTIC);
    }

    /**
     * Requests a change of the device name.
     * @param deviceName new name for the device (maximum size is 22 characters)
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public boolean setDeviceName(String deviceName) {
        int length = deviceName.length();
        if (1 <= length && length <= 22) {
            BluetoothGattCharacteristic c = mCharacteristicMap.get(NAME_WRITE_CHARACTERISTIC);
            c.setValue(deviceName.getBytes(Charset.forName("ASCII")));
            return mGatt.writeCharacteristic(c);
        } else {
            Log.e(TAG, "In setDeviceName(), the length of deviceName should be between 1 and 22, but is set to " + length);
            return false;
        }
    }

    /**
     * Requests a read of the factory accelerometer offset values on the connected device.
     * The event {@link ESenseEventListener#onAccelerometerOffsetRead(int, int, int)} is fired when the values have been read from the connected device.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public boolean getAccelerometerOffset() {
        return readCharacteristic(ACCELEROMETER_OFFSET_CHARACTERISTIC);
    }

    /**
     * Requests a read of the sensor configuration on the connected device.
     * The event {@link ESenseEventListener#onSensorConfigRead(ESenseConfig)} is fired when the configuration has been read from the connected device.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public boolean getSensorConfig() {
        return readCharacteristic(SENSOR_CONFIG_CHARACTERISTIC);
    }

    /**
     * Requests a change of the sensor configuration on the connected device.
     * @param config new configuration to be written on the device
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public boolean setSensorConfig(ESenseConfig config) {
        if(config != null) {
            BluetoothGattCharacteristic c = mCharacteristicMap.get(SENSOR_CONFIG_CHARACTERISTIC);
            byte[] bytes = config.prepareCharacteristicData();
            bytes[1] = getCheckSum(bytes,1);
            c.setValue(bytes);
            return mGatt.writeCharacteristic(c);
        } else {
            Log.e(TAG, "In setSensorConfig(), config is set to null!!");
            return false;
        }
    }

    /**
     * Requests a read of the parameter values of advertisement and connection interval on the connected device
     * The event {@link ESenseEventListener#onAdvertisementAndConnectionIntervalRead(int, int, int, int)} is fired when the parameter values have been read from the connected device.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public boolean getAdvertisementAndConnectionInterval() {
        return readCharacteristic(ADV_CONN_CHARACTERISTIC);
    }

    /**
     * Requests a change of the advertisement and connection intervals.
     *
     * <p>
     *     Condition for advertisement interval: 1) the minimum interval should be greater than or equal to 100, 2) the maximum interval should be less than or equal to 2000, 3) the maximum interval should be greater than or equal to the minimum interval.
     * </p>
     * <p>
     *     Condition for connection interval: 1) the minimum interval should be greater than or equal to 20. 2) the maximum interval should be less than or equal to 2000, 3) the difference between the maximum and minimum intervals should be greater than or equal to 20.
     * </p>
     * @param advMinInterval minimum advertisement interval (unit: milliseconds)
     * @param advMaxInterval maximum advertisement interval (unit: milliseconds)
     * @param connMinInterval minimum connection interval (unit: milliseconds)
     * @param connMaxInterval maximum connection interval (unit: mlliseconds)
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public boolean setAdvertisementAndConnectiontInterval(int advMinInterval, int advMaxInterval, int connMinInterval, int connMaxInterval) {
        short adv_min_interval;
        short adv_max_interval;
        short conn_min_interval;
        short conn_max_interval;

        if (100 <= advMinInterval && advMinInterval <= advMaxInterval && advMaxInterval <= 2000) {
            adv_min_interval = (short) (advMinInterval / 0.625);
            adv_max_interval = (short) (advMaxInterval / 0.625);
        } else {
            if (advMinInterval < 100)
                Log.e(TAG, "In setAdvertisementAndConnectionInterval(), advMinInterval should be greater than or equal to 100, but is set to " + advMinInterval);
            if (advMaxInterval > 2000)
                Log.e(TAG, "In setAdvertisementAndConnectionInterval(), advMaxInterval should be less than or equal to 2000, but is set to " + advMaxInterval);
            if (advMinInterval > advMaxInterval)
                Log.e(TAG, "In setAdvertisementAndConnectionInterval(), advMaxInterval should be greater than or equal to advMinInterval, but advMinInterval is set to " + advMinInterval + " and advMaxInterval is set to " + advMaxInterval);

            return false;
        }

        if (20 <= connMinInterval && connMaxInterval <= 2000 && (connMaxInterval-connMinInterval) >= 20) {
            conn_min_interval = (short) (connMinInterval / 1.25);
            conn_max_interval = (short) (connMaxInterval / 1.25);
        } else {
            if (connMinInterval < 20)
                Log.e(TAG, "In setAdvertisementAndConnectionInterval(), connMinInterval should be greater than or equal to 20, but is set to " + connMinInterval);
            if (connMaxInterval > 2000)
                Log.e(TAG, "In setAdvertisementAndConnectionInterval(), connMaxInterval should be less than or equal to 2000, but is set to " + connMaxInterval);
            if ((connMinInterval-connMaxInterval) < 20)
                Log.e(TAG, "In setAdvertisementAndConnectionInterval(), the difference between connMaxInterval and connMinInterval should be greater than or equal to 20, but connMinInterval is set to " + connMinInterval + " and connMaxInterval is set to " + connMaxInterval);

            return false;
        }

        byte[] bytes = new byte[]{0x57, 0x00, 0x08,
                (byte) (adv_min_interval / 256), (byte) (adv_min_interval % 256), (byte) (adv_max_interval / 256), (byte)(adv_max_interval % 256),
                (byte) (conn_min_interval / 256), (byte) (conn_min_interval % 256), (byte) (conn_max_interval / 256), (byte)(conn_max_interval % 256)};

        bytes[1] = getCheckSum(bytes,1);
        BluetoothGattCharacteristic c = mCharacteristicMap.get(CONFIG_CHARACTERISTIC);
        c.setValue(bytes);
        return mGatt.writeCharacteristic(c);
    }

    /**
     * Requests a read of the battery voltage of the connected device.
     * The event {@link ESenseEventListener#onBatteryRead(double)} is fired when the voltage has been read.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public boolean getBatteryVoltage() {
        return readCharacteristic(BATTERY_CHARACTERISTIC);
    }

    /**
     * Registers a sensor listener and starts sensor sampling on the connected device.
     * The event {@link ESenseSensorListener#onSensorChanged(ESenseEvent)} is fired every time a new sample is available from the connected device.
     * @param listener sensor listener
     * @param samplingRate sensor sampling rate in Hz (min: 1 - max: 100)
     * @return {@link SamplingStatus#STARTED} if the sampling was started successfully,
     *         {@link SamplingStatus#ERROR} if the parameter is incorrect,
     *         {@link SamplingStatus#DEVICE_DISCONNECTED} if the device is disconnected
     */
    public SamplingStatus registerSensorListener(ESenseSensorListener listener, int samplingRate) {
        if (!isConnected()) {
            Log.e(TAG, "eSense device is not connected");
            return SamplingStatus.DEVICE_DISCONNECTED;
        }
        if (listener == null){
            Log.e(TAG, "In registerSensorListener(), listener is set to null");
            return SamplingStatus.ERROR;
        }
        if(samplingRate < 1 || 100 < samplingRate){
            Log.e(TAG, "In registerSensorListener(), samplingRate should be set between 1 and 100, but is set to " + samplingRate);
            return SamplingStatus.ERROR;
        }
        BluetoothGattCharacteristic c = mCharacteristicMap.get(CONFIG_CHARACTERISTIC);
        byte[] bytes = new byte[]{0x53, 0x00, 0x02, 0x01, (byte) samplingRate};
        bytes[1] = getCheckSum(bytes,1);
        c.setValue(bytes);
        mGatt.writeCharacteristic(c);

        mSensorListener = listener;
        enableNotification(SENSOR_CHARACTERISTIC,true);
        return SamplingStatus.STARTED;
    }

    /**
     * Unregisters a sensor listener and stops sensor sampling on the connected device
     */
    public void unregisterSensorListener(){
        BluetoothGattCharacteristic c = mCharacteristicMap.get(CONFIG_CHARACTERISTIC);

        byte[] IMU_STOP_CMD = new byte[]{0x53, 0x02, 0x02, 0x00, 0x00};
        c.setValue(IMU_STOP_CMD);
        mGatt.writeCharacteristic(c);

        enableNotification(SENSOR_CHARACTERISTIC,false);
        mSensorListener = null;
    }

    /**
     * Registers an event listener and enables notifications on button events.
     * @param listener event listener
     * @return <code>true</code> if the listener was registered correctly
     *         <code>false</code> otherwise
     */
    public boolean registerEventListener(ESenseEventListener listener){
        if(!isConnected() || listener == null){
            return false;
        }

        mEventListener = listener;
        enableNotification(BUTTON_CHARACTERISTIC,true);
        return true;
    }

    /**
     * Unregisters a sensor listener and stops notifications on button events
     */
    public void unregisterEventListener(){
        enableNotification(BUTTON_CHARACTERISTIC,false);
        mEventListener = null;
    }

    /**
     * Checks if the device is connected or not
     * @return <code>true</code> if device is connected
     *         <code>false</code> otherwise
     */
    public boolean isConnected() {
        return (mBluetoothManager.getConnectionState(mDevice, BluetoothProfile.GATT) == BluetoothProfile.STATE_CONNECTED);
    }

    /**
     * Disconnects device.
     * The event {@link ESenseConnectionListener#onDisconnected(ESenseManager manager)} is fired after the disconnection has taken place.
     * @return <code>true</code> if the disconnection was successfully made
     *         <code>false</code> otherwise
     */
    public boolean disconnect(){
        if(isConnected()) {
            mGatt.disconnect();
            return true;
        }
        else {
            return false;
        }
    }

    /**
     * Initiates a connection procedure. The phone will first scan for the device with a given name and. Then, if found, it will try to connect.
     * The events {@link ESenseConnectionListener#onDeviceFound(ESenseManager manager)}, {@link ESenseConnectionListener#onDeviceNotFound(ESenseManager manager)} or {@link ESenseConnectionListener#onConnected(ESenseManager manager)} are fired at different stages of the procedure.
     * @param timeout scan timeout in milli seconds
     * @return <code>true</code> if the procedure started successfully
     *         <code>false</code> otherwise
     */
    public boolean connect(int timeout){
        try {
            findDevice(timeout);
            return true;
        } catch(RuntimeException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Scans for the device with the name specified when the manager was constructed.
     * The events {@link ESenseConnectionListener#onDeviceFound(ESenseManager manager)}, {@link ESenseConnectionListener#onDeviceNotFound(ESenseManager manager)} are fired if the device has been found or if it was not found.
     * @param timeout in milliseconds
     */
    private void findDevice(final int timeout) {
        new Thread(new Runnable() {
            public void run() {
                CountDownLatch deviceFoundLatch = new CountDownLatch(1);
                ESenseScanner scanner = new ESenseScanner(mDeviceName, mBluetoothManager, deviceFoundLatch);
                scanner.scan();
                try {
                    deviceFoundLatch.await(timeout, TimeUnit.MILLISECONDS);
                } catch (InterruptedException e) {
                    scanner.stopScan();
                    e.printStackTrace();
                }

                if(deviceFoundLatch.getCount() == 0){
                    mDevice = scanner.getDevice();
                    if(mConnectionListener != null) {
                        mConnectionListener.onDeviceFound(ESenseManager.this);
                    }

                    // Device found so initiate connection
                    mGatt = mDevice.connectGatt(mContext, false, mGattCallback, BluetoothDevice.TRANSPORT_LE);

                } else {
                    scanner.stopScan();
                    if(mConnectionListener != null) {
                        mConnectionListener.onDeviceNotFound(ESenseManager.this);
                    }
                }
            }
        }).start();
    }

    /**
     * Collection of GATT callbacks
     */
    private class ESenseBGattCallback extends BluetoothGattCallback{

        /**
         * Collects UUID of characteristics
         * @param characteristic Bluetooth characteristic
         * @return String of UUID of the characteristic
         */
        private String getKey(BluetoothGattCharacteristic characteristic){
            return characteristic.getUuid().toString().toLowerCase();
        }

        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                gatt.discoverServices();
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                gatt.close();
                mCharacteristicMap.clear();
                if(mConnectionListener != null) {
                    mConnectionListener.onDisconnected(ESenseManager.this);
                }
            }

        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            for (BluetoothGattService s : gatt.getServices()) {
                for (BluetoothGattCharacteristic c : s.getCharacteristics()) {
                    mCharacteristicMap.put(getKey(c), c);
                }
            }

            // Fire onConnected event after all the services have been discovered
            if(mConnectionListener != null) {
                mConnectionListener.onConnected(ESenseManager.this);
            }
        }

        /**
         * Delivers appropriate events after each read operation
         */
        @Override
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic c, int status) {
            if(status == BluetoothGatt.GATT_SUCCESS) {
                String key = getKey(c);
                switch (key) {
                    case DEVICE_NAME_CHARACTERISTIC:
                        if (mEventListener != null) {
                            StringBuilder deviceName = new StringBuilder();
                            for (byte b : c.getValue()) {
                                deviceName.append((char) b);
                            }

                            mEventListener.onDeviceNameRead(deviceName.toString());
                        }
                        break;

                    case ADV_CONN_CHARACTERISTIC:
                        if (mEventListener != null) {
                            byte[] b = c.getValue();
                            if (checkCheckSum(b, 1)) {
                                mEventListener.onAdvertisementAndConnectionIntervalRead(
                                        (int) (((b[3] & 0xff) * 256 + (b[4] & 0xff)) * 0.625),
                                        (int) (((b[5] & 0xff) * 256 + (b[6] & 0xff)) * 0.625),
                                        (int) (((b[7] & 0xff) * 256 + (b[8] & 0xff)) * 1.25),
                                        (int) (((b[9] & 0xff) * 256 + (b[10] & 0xff)) * 1.25));
                            }
                        }
                        break;

                    case BATTERY_CHARACTERISTIC:
                        if (mEventListener != null) {
                            byte[] bytes = c.getValue();
                            if (checkCheckSum(bytes, 1)) {
                                mEventListener.onBatteryRead(((bytes[3] & 0xff) * 256 + (bytes[4] & 0xff)) / 1000.0);
                            }
                        }
                        break;

                    case SENSOR_CONFIG_CHARACTERISTIC:
                        if (mEventListener != null) {
                            byte[] bytes = c.getValue();
                            if (checkCheckSum(bytes, 1)) {
                                ESenseConfig config = new ESenseConfig(bytes);
                                mEventListener.onSensorConfigRead(config);
                            }
                        }
                        break;

                    case ACCELEROMETER_OFFSET_CHARACTERISTIC:
                        if (mEventListener != null) {
                            byte[] bytes = c.getValue();
                            if (checkCheckSum(bytes, 1)) {
                                // Format is in +-16G in which 1g = 2048
                                int offsetX = ((int) (bytes[9]) << 8) | (bytes[10] & 0xff);
                                int offsetY = ((int) (bytes[11]) << 8) | (bytes[12] & 0xff);
                                int offsetZ = ((int) (bytes[13]) << 8) | (bytes[14] & 0xff);
                                mEventListener.onAccelerometerOffsetRead(offsetX, offsetY, offsetZ);

                            }
                        }
                        break;
                }
            }
        }

        @Override
        public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic c, int status){
            if(status == BluetoothGatt.GATT_SUCCESS) {
                String key = getKey(c);
                switch (key) {
                    case NAME_WRITE_CHARACTERISTIC:
                        StringBuilder deviceName = new StringBuilder();
                        for (byte b : c.getValue()) {
                            deviceName.append((char) b);
                        }

                        // Update the internal name if the write operation was successful
                        mDeviceName = deviceName.toString();
                        break;
                }
            }
        }

        /**
         * Delivers appropriate events when notification events are received from the connected device
         */
        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic c){
            String key = getKey(c);
            switch(key){
                case SENSOR_CHARACTERISTIC:
                    if(mSensorListener != null){
                        byte[] bytes = c.getValue();
                        if(checkCheckSum(bytes, 2)) {
                            short[] acc = new short[3];
                            short[] gyro = new short[3];
                            for (int i = 0; i < 3; i++) {
                                acc[i] = (short) ((bytes[i*2+10] * 256) + bytes[i*2+11]);
                                gyro[i] = (short) ((bytes[i*2+4] * 256) + bytes[i*2+5]);
                            }

                            ESenseEvent eSenseEvent = new ESenseEvent(acc, gyro);
                            eSenseEvent.setTimestamp(System.currentTimeMillis());
                            eSenseEvent.setPacketIndex(bytes[1] < 0 ? bytes[1] + 256 : bytes[1]);
                            mSensorListener.onSensorChanged(eSenseEvent);
                        }
                    }
                    break;

                case BUTTON_CHARACTERISTIC:
                    if(mEventListener != null) {
                        byte[] bytes = c.getValue();
                        if(checkCheckSum(bytes,1)) {
                            int value = bytes[3];
                            mEventListener.onButtonEventChanged(value == 1);
                        }
                    }
                    break;
            }
        }
    }
}