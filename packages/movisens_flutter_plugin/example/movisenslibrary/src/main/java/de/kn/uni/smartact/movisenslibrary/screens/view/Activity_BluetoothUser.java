package de.kn.uni.smartact.movisenslibrary.screens.view;

import android.databinding.DataBindingUtil;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.databinding.ActivityBluetoothUserBinding;
import de.kn.uni.smartact.movisenslibrary.screens.viewmodel.Handler_BluetoothUser;

public class Activity_BluetoothUser extends AppCompatActivity {

    Handler_BluetoothUser handler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        handler = new Handler_BluetoothUser(this);

        ActivityBluetoothUserBinding binding = DataBindingUtil.setContentView(this, R.layout.activity_bluetooth_user);
        binding.setHandler(handler);
    }

}
