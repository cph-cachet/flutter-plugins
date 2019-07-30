package io.esense.esenselib;

public class ESenseEvent {
    private long timestamp;  //phone's timestamp
    private int packetIndex;
    private short[] accel;   //3-elements array with X, Y and Z axis for accelerometer
    private short[] gyro;    //3-elements array with X, Y and Z axis for gyroscope

    /**
     * Constructs an empty event
     */
    ESenseEvent(){
        this(new short[3], new short[3]);
    }

    /**
     * Constructs an event with values received from the device
     * @param accel ADC values for the accelerometer
     * @param gyro ADC values for the gyroscope
     */
    ESenseEvent(short[] accel, short[] gyro){
        this.accel = accel;
        this.gyro = gyro;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public int getPacketIndex() {
        return packetIndex;
    }

    public void setPacketIndex(int packetIndex) {
        this.packetIndex = packetIndex;
    }

    public short[] getAccel() {
        return accel;
    }

    public void setAccel(short[] accel) {
        this.accel = accel;
    }

    public short[] getGyro() {
        return gyro;
    }

    public void setGyro(short[] gyro) {
        this.gyro = gyro;
    }

    /**
     * Converts current ADC accelerometer values to acceleration in g
     * @param config device configuration
     * @return acceleration in g on X, Y and Z axis
     */
    public double[] convertAccToG(ESenseConfig config){
        double[] data = new double[3];
        for (int i = 0; i < 3; i++) {
            data[i] = (accel[i] / config.getAccSensitivityFactor());
        }

        return(data);
    }

    /**
     * Converts current ADC gyroscope values to rotational speed in degrees/second
     * @param config device configuration
     * @return rotational speed in deg/s on X, Y and Z axis
     */
    public double[] convertGyroToDegPerSecond(ESenseConfig config){
        double[] data = new double[3];
        for (int i = 0; i < 3; i++) {
            data[i] = (gyro[i] / config.getGyroSensitivityFactor());
        }

        return(data);
    }
}
