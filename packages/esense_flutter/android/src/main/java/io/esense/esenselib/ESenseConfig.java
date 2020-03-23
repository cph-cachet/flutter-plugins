package io.esense.esenselib;

public class ESenseConfig {

    /**
     * Gyroscope full scale range in +-degrees/second
     */
    public enum GyroRange {
        DEG_250, DEG_500, DEG_1000, DEG_2000
    }

    /**
     * Accelerometer full scale range in +-g
     */
    public enum AccRange {
        G_2, G_4, G_8, G_16
    }

    /**
     * Gyroscope low pass filter configuration. Each value except DISABLED represents the bandwidth of the filter in Hz.
     */
    public enum GyroLPF {
        BW_250, BW_184, BW_92, BW_41, BW_20, BW_10, BW_5, BW_3600, DISABLED
    }

    /**
     * Accelerometer low pass filter configuration. Each value except DISABLED represents the bandwidth of the filter in Hz.
     */
    public enum AccLPF {
        BW_460, BW_184, BW_92, BW_41, BW_20, BW_10, BW_5, DISABLED
    }

    private GyroRange gyroRange;
    private AccRange accRange;
    private GyroLPF gyroLPF;
    private AccLPF accLPF;

    /**
     * Constructs a configuration object with the specified ranges and low pass filter values
     * @param accRange accelerometer range
     * @param gyroRange gyroscope range
     * @param accLPF accelerometer low pass filter configuration
     * @param gyroLPF gyroscope low pass filter configuration
     */
    public ESenseConfig(AccRange accRange, GyroRange gyroRange, AccLPF accLPF, GyroLPF gyroLPF){
        this.accRange = accRange;
        this.gyroRange = gyroRange;
        this.accLPF = accLPF;
        this.gyroLPF = gyroLPF;
    }

    /**
     * Constructs a configuration object from the bytes read from the device
     * @param charaterictic_data bytes read from the device
     */
    public ESenseConfig(byte[] charaterictic_data){
        gyroLPF = parseGyroLPF(charaterictic_data);
        accLPF = parseAccLPF(charaterictic_data);
        gyroRange = parseGyroRange(charaterictic_data);
        accRange = parseAccRange(charaterictic_data);
    }

    /**
     * Constructs a default configuration object
     * Acc range = +-4g
     * Gyro range = +-1000deg/s
     * Acc LPF = bandwith 5Hz
     * Gyro LPf = bandwith 5Hz
     */
    public ESenseConfig(){
        this(AccRange.G_4, GyroRange.DEG_1000, AccLPF.BW_5, GyroLPF.BW_5);
    }

    /**
     * Extracts gyroscope low pass filter configuration from bytes read from the device
     * @param data bytes read from the device
     * @return Gyro LPF configuration
     */
    public static ESenseConfig.GyroLPF parseGyroLPF(byte[] data){
        int lpf_enabled = data[4] & 0x3;
        if(lpf_enabled == 1 || lpf_enabled == 2){
            return(ESenseConfig.GyroLPF.DISABLED);
        } else {
            ESenseConfig.GyroLPF lpf = ESenseConfig.GyroLPF.values()[data[3] & 0x7];
            return(lpf);
        }
    }

    /**
     * Extracts accelerometer low pass filter configuration from bytes read from the device
     * @param data bytes read from the device
     * @return accelerometer LPF configuration
     */
    public static ESenseConfig.AccLPF parseAccLPF(byte[] data){
        int lpf_enabled = (data[6] & 0x8) >> 3;
        if(lpf_enabled == 1){
            return(ESenseConfig.AccLPF.DISABLED);
        } else {
            ESenseConfig.AccLPF lpf = ESenseConfig.AccLPF.values()[data[6] & 0x7];
            return(lpf);
        }
    }

    /**
     * Extracts gyroscope full scale range configuration from bytes read from the device
     * @param data bytes read from the device
     * @return Gyro range configuration
     */
    public static ESenseConfig.GyroRange parseGyroRange(byte[] data){
        return(ESenseConfig.GyroRange.values()[(data[4] & 0x18) >> 3]);
    }

    /**
     * Extracts accelerometer full scale range configuration from bytes read from the device
     * @param data bytes read from the device
     * @return accelerometer range configuration
     */
    public static ESenseConfig.AccRange parseAccRange(byte[] data){
        return(ESenseConfig.AccRange.values()[(data[5] & 0x18) >> 3]);
    }

    /**
     * Convert current configuration objects in bytes to write on the configuration characteristic of the device
     * @return bytes to write on the characteristic
     */
    public byte[] prepareCharacteristicData(){
        byte[] data = {0x59, 0x00, 0x04, 0x06, 0x08, 0x08, 0x06};
        data = setGyroLPFInBytes(data);
        data = setAccLPFInBytes(data);
        data = setAccRangeInBytes(data);
        data = setGyroRangeInBytes(data);
        return(data);
    }

    private byte[] setGyroLPFInBytes(byte[] data) {
        if(this.gyroLPF == ESenseConfig.GyroLPF.DISABLED){
            data[4] = (byte)((data[4] & 0xfc) | 0x1);
        } else {
            data[4] = (byte)((data[4] & 0xfc));
            data[3] = (byte)((data[3] & 0xf8) | this.gyroLPF.ordinal());
        }

        return(data);
    }

    private byte[] setAccLPFInBytes(byte[] data) {
        if(this.accLPF == ESenseConfig.AccLPF.DISABLED){
            data[6] = (byte)((data[6] & 0xf7) | (0x1 << 3));
        } else {
            data[6] = (byte)((data[6] & 0xf7));
            data[6] = (byte)((data[6] & 0xf8) | this.accLPF.ordinal());
        }

        return(data);
    }

    private byte[] setGyroRangeInBytes(byte[] data){
        data[4] = (byte)((data[4] & 0xe7) | (this.gyroRange.ordinal() << 3));
        return(data);
    }

    private byte[] setAccRangeInBytes(byte[] data){
        data[5] = (byte)((data[5] & 0xe7) | (this.accRange.ordinal() << 3));
        return(data);
    }

    /**
     * Get accelerometer sensitivity factor for the current configuration
     * @return accelerometer sensitivity factor
     */
    public double getAccSensitivityFactor(){
        switch(accRange){
            case G_2:
                return 16384;
            case G_4:
                return 8192;
            case G_8:
                return 4096;
            case G_16:
                return 2048;
        }

        return 1;
    }

    /**
     * Get gyroscope sensitivity factor for the current configuration
     * @return gyroscope sensitivity factor
     */
    public double getGyroSensitivityFactor(){
        switch(gyroRange){
            case DEG_250:
                return 131;
            case DEG_500:
                return 65.5;
            case DEG_1000:
                return 32.8;
            case DEG_2000:
                return 16.4;
        }

        return 1f;
    }

    public GyroRange getGyroRange() {
        return gyroRange;
    }

    public void setGyroRange(GyroRange gyroRange) {
        this.gyroRange = gyroRange;
    }

    public AccRange getAccRange() {
        return accRange;
    }

    public void setAccRange(AccRange accRange) {
        this.accRange = accRange;
    }

    public GyroLPF getGyroLPF() {
        return gyroLPF;
    }

    public void setGyroLPF(GyroLPF gyroLPF) {
        this.gyroLPF = gyroLPF;
    }

    public AccLPF getAccLPF() {
        return accLPF;
    }

    public void setAccLPF(AccLPF accLPF) {
        this.accLPF = accLPF;
    }
}