package de.kn.uni.smartact.movisenslibrary.screens.view;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.databinding.DataBindingUtil;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.text.InputType;
import android.util.Log;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.Toast;

import java.util.Calendar;
import java.util.HashMap;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.SensorApplication;
import de.kn.uni.smartact.movisenslibrary.databinding.ActivityBluetoothStartBinding;
import de.kn.uni.smartact.movisenslibrary.screens.viewmodel.Handler_BluetoothStart;


public class Activity_BluetoothStart extends AppCompatActivity {

//    private boolean isPwPromptActive = false;
    private Handler_BluetoothStart handler;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d("appFlow","Step 2:  Inside Activity_BluetoothStart On create");
        HashMap<String, String> userDataMap = (HashMap<String, String>) this.getIntent().getSerializableExtra("user_data");
        Log.d("ActivityBlueToothStart", userDataMap.toString());
        handler = new Handler_BluetoothStart(this, userDataMap);

        ActivityBluetoothStartBinding binding = DataBindingUtil.setContentView(this, R.layout.activity_bluetooth_start);

        binding.setHandler(handler);
//        handler.startSampling();
    }

}
