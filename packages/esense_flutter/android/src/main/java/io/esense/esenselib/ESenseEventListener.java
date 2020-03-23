package io.esense.esenselib;

public interface ESenseEventListener {
    /**
     * Called when the information on battery voltage has been received
     * @param voltage battery voltage in Volts
     */
    void onBatteryRead(double voltage);

    /**
     * Called when the button event has changed
     * @param pressed true if the button is pressed, false if it is released
     */
    void onButtonEventChanged(boolean pressed);

    /**
     * Called when the information on advertisement and connection interval has been received
     * @param minAdvertisementInterval minimum advertisement interval (unit: milliseconds)
     * @param maxAdvertisementInterval maximum advertisement interval (unit: milliseconds)
     * @param minConnectionInterval minimum connection interval (unit: milliseconds)
     * @param maxConnectionInterval maximum connection interval (unit: milliseconds)
     */
    void onAdvertisementAndConnectionIntervalRead(int minAdvertisementInterval, int maxAdvertisementInterval, int minConnectionInterval, int maxConnectionInterval);

    /**
     * Called when the information on the device name has been received
     * @param deviceName name of the device
     */
    void onDeviceNameRead(String deviceName);

    /**
     * Called when the information on sensor configuration has been received
     * @param config current sensor configuration
     */
    void onSensorConfigRead(ESenseConfig config);

    /**
     * Called when the information on accelerometer offset has been received
     * @param offsetX x-axis factory offset
     * @param offsetY y-axis factory offset
     * @param offsetZ z-axis factory offset
     */
    void onAccelerometerOffsetRead(int offsetX, int offsetY, int offsetZ);
}
