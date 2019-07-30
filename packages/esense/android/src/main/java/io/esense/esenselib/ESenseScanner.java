package io.esense.esenselib;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.util.Log;

import java.util.concurrent.CountDownLatch;

public class ESenseScanner extends ScanCallback {
    private final String TAG = "ESenseScanner";

    private CountDownLatch mDeviceFoundLatch;
    private BluetoothLeScanner mBluetoothLeScanner;
    private BluetoothDevice mDevice;
    private boolean mScanning;
    private String mDeviceName;

    /**
     * Constructs an eSense scanner
     * @param name name of the eSense device to look for during a scan
     * @param bluetoothManager BluetoothManager object
     * @param deviceFoundLatch CountDownLatch object
     */
    protected ESenseScanner(String name, BluetoothManager bluetoothManager, CountDownLatch deviceFoundLatch){
        mDeviceName = name;
        mBluetoothLeScanner = bluetoothManager.getAdapter().getBluetoothLeScanner();
        this.mDeviceFoundLatch = deviceFoundLatch;
    }

    /**
     * Performs eSense scanning
     */
    protected void scan(){
        ScanSettings settings = new ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build();
        mBluetoothLeScanner.startScan(null, settings, this);
        mScanning = true;
        Log.d(TAG,"Start scan");
    }

    @Override
    public void onScanResult(int callbackType, ScanResult result) {
        super.onScanResult(callbackType, result);
        BluetoothDevice _device = result.getDevice();
        if (_device != null && _device.getName() != null && _device.getName().matches(mDeviceName)) {
            stopScan();
            mDevice = _device;

            Log.i(TAG,"mac address : " + mDevice.getAddress() + ", name : " + mDevice.getName());
            mDeviceFoundLatch.countDown();
        }
    }

    /**
     * Stops eSense scanning
     */
    protected synchronized void stopScan() {
        if (mBluetoothLeScanner != null && mScanning) {
            mBluetoothLeScanner.stopScan(this);
            mScanning = false;
            Log.i(TAG,"Stop scan");
        }
    }

    /**
     * Checks if scanning is being performed.
     * @return <code>true</code> if scanning is being performed
     *         <code>false</code> otherwise
     */
    protected boolean isScanning(){
        return mScanning;
    }

    /**
     * Gets the BluetoothDevice object.
     */
    protected BluetoothDevice getDevice(){
        return(mDevice);
    }
}
