package de.kn.uni.smartact.movisenslibrary.screens.viewmodel;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.model.UserData;
import de.kn.uni.smartact.movisenslibrary.screens.adapter.BluetoothDeviceAdapter;
import de.kn.uni.smartact.movisenslibrary.screens.adapter.BluetoothDeviceHandler;
import de.kn.uni.smartact.movisenslibrary.utils.BindableBoolean;

import static android.bluetooth.le.ScanSettings.CALLBACK_TYPE_ALL_MATCHES;
import static android.bluetooth.le.ScanSettings.MATCH_MODE_AGGRESSIVE;
import static android.bluetooth.le.ScanSettings.MATCH_NUM_MAX_ADVERTISEMENT;
import static android.bluetooth.le.ScanSettings.SCAN_MODE_BALANCED;


public class Handler_BluetoothDeviceScan {

    private Handler_BluetoothDeviceScan mThisHandler;
    private Activity mContext;
    private BluetoothDeviceAdapter mAdapter;
    private List<BluetoothDeviceHandler> mDeviceList;

    private BluetoothAdapter mBluetoothAdapter;
    private Handler mHandler;

    public static final int REQUEST_ENABLE_BT = 1;
    // Stops scanning after 20 seconds.
    private static final long SCAN_PERIOD = 20000;

    public BindableBoolean isScanning;

    public Handler_BluetoothDeviceScan(Activity context) {
        mThisHandler = this;
        mContext = context;
        mHandler = new Handler();
        mDeviceList = new ArrayList<>();
        isScanning = new BindableBoolean();


        // Use this check to determine whether BLE is supported on the device.
        // Then you can
        // selectively disable BLE-related features.
        if (!context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            Toast.makeText(context, R.string.ble_not_supported, Toast.LENGTH_SHORT).show();
            context.finish();
        }

        // Initializes a Bluetooth adapter. For API level 18 and above, get a
        // reference to
        // BluetoothAdapter through BluetoothManager.
        final BluetoothManager bluetoothManager = (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
        mBluetoothAdapter = bluetoothManager.getAdapter();

        // Checks if Bluetooth is supported on the device.
        if (mBluetoothAdapter == null) {
            Toast.makeText(context, R.string.error_bluetooth_not_supported, Toast.LENGTH_SHORT).show();
            context.finish();
            return;
        }

        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            context.startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
            return;
        }

        scanLeDevice(true);
    }

    public void scanLeDevice(final Boolean enabled) {
        if (enabled) {
            // Stops scanning after a pre-defined scan period.
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    isScanning.set(false);
                    mBluetoothAdapter.getBluetoothLeScanner().stopScan(mLeScanCallback);
                }
            }, SCAN_PERIOD);

            isScanning.set(true);

            List<ScanFilter> scanFilterList = new ArrayList<>();
            ScanFilter.Builder filterBuilder = new ScanFilter.Builder();
            //Pattern p = Pattern.compile("^MOVISENS Sensor.*$");
            //filterBuilder.setDeviceName(p.pattern());// [A-Za-z0-9]");
            scanFilterList.add(filterBuilder.build());

            ScanSettings.Builder settingsBuilder = new ScanSettings.Builder();
            settingsBuilder.setCallbackType(CALLBACK_TYPE_ALL_MATCHES);
            settingsBuilder.setMatchMode(MATCH_MODE_AGGRESSIVE);
            settingsBuilder.setNumOfMatches(MATCH_NUM_MAX_ADVERTISEMENT);
            settingsBuilder.setReportDelay(0);
            settingsBuilder.setScanMode(SCAN_MODE_BALANCED);

            mBluetoothAdapter.getBluetoothLeScanner().startScan(scanFilterList, settingsBuilder.build(), mLeScanCallback);
        } else {
            isScanning.set(false);
            mBluetoothAdapter.getBluetoothLeScanner().stopScan(mLeScanCallback);
        }
    }

    // Device scan callback.
    private ScanCallback mLeScanCallback = new ScanCallback() {

        @Override
        public void onScanResult(int callbackType, final ScanResult result) {
//            Log.d("BLE", "onScanResult: " + result.getDevice().getName());


            mContext.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (result.getDevice().getName() != null && result.getDevice().getName().startsWith("MOVISENS Sensor")) {
                        Boolean alreadyInList = false;
                        for (BluetoothDeviceHandler deviceHandler:mDeviceList) {
                            if (deviceHandler.device.equals(result.getDevice()))
                                alreadyInList = true;
                        }

                        if (!alreadyInList) {
                            mDeviceList.add(new BluetoothDeviceHandler(result.getDevice(),mThisHandler));
                            mAdapter.notifyDataSetChanged();
                        }
                    }

                }
            });
        }
    };

    public void selectDevice(BluetoothDevice device){
        String sensor_name = device.getName().replace("MOVISENS", "").trim();

        UserData user = new UserData(mContext);
        user.sensor_address.set(device.getAddress());
        user.sensor_name.set(sensor_name);
        user.saveToDB(mContext);
        mContext.finish();
    }

    public BluetoothDeviceAdapter getListAdapter(){
        if (mAdapter == null) {
            mAdapter = new BluetoothDeviceAdapter(mDeviceList);
        }

        return mAdapter;
    }

    public void refresh(){
        mDeviceList.clear();
        mAdapter.notifyDataSetChanged();
        scanLeDevice(true);
    }
}
