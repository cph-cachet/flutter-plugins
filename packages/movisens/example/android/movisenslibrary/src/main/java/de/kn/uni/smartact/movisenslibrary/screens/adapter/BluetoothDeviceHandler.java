package de.kn.uni.smartact.movisenslibrary.screens.adapter;

import android.bluetooth.BluetoothDevice;

import de.kn.uni.smartact.movisenslibrary.screens.viewmodel.Handler_BluetoothDeviceScan;

public class BluetoothDeviceHandler {

    public BluetoothDevice device;
    private Handler_BluetoothDeviceScan parent;

    public BluetoothDeviceHandler(BluetoothDevice device, Handler_BluetoothDeviceScan parent){
        this.device = device;
        this.parent = parent;
    }

    public void select(){
        parent.selectDevice(device);
    }
}
