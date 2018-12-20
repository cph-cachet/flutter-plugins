package de.kn.uni.smartact.movisenslibrary.screens.view;

import android.app.Activity;
import android.content.Intent;
import android.databinding.DataBindingUtil;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.MenuItem;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.screens.viewmodel.Handler_BluetoothDeviceScan;
import de.kn.uni.smartact.movisenslibrary.databinding.ActivityBluetoothDeviceScanBinding;

import static de.kn.uni.smartact.movisenslibrary.screens.viewmodel.Handler_BluetoothDeviceScan.REQUEST_ENABLE_BT;

public class Activity_BluetoothDeviceScan extends AppCompatActivity {

    Handler_BluetoothDeviceScan handler;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        handler = new Handler_BluetoothDeviceScan(this);

        ActivityBluetoothDeviceScanBinding binding =
                DataBindingUtil.setContentView(this, R.layout.activity_bluetooth_device_scan);
        binding.setHandler(handler);

        RecyclerView recyclerView = (RecyclerView) findViewById(R.id.rView);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.setAdapter(handler.getListAdapter());
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // User chose not to enable Bluetooth.
        if (requestCode == REQUEST_ENABLE_BT && resultCode == Activity.RESULT_CANCELED) {
            finish();
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                handler.scanLeDevice(false);
                break;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        handler.scanLeDevice(false);
        super.onBackPressed();
    }

}
