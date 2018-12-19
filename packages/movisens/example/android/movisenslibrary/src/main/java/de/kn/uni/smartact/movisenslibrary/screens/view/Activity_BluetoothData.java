package de.kn.uni.smartact.movisenslibrary.screens.view;

import android.databinding.DataBindingUtil;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.databinding.ActivityBluetoothDataBinding;
import de.kn.uni.smartact.movisenslibrary.screens.viewmodel.Handler_BluetoothData;


public class Activity_BluetoothData extends AppCompatActivity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Handler_BluetoothData handler = new Handler_BluetoothData(this);

        ActivityBluetoothDataBinding binding = DataBindingUtil.setContentView(this, R.layout.activity_bluetooth_data);
        binding.setHandler(handler);

        RecyclerView recyclerView = (RecyclerView) findViewById(R.id.rView);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.setAdapter(handler.getListAdapter());
    }

}
