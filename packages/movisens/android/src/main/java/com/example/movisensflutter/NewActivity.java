package com.example.movisensflutter;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import de.kn.uni.smartact.movisenslibrary.screens.view.Activity_BluetoothStart;

public class NewActivity extends AppCompatActivity
{


    private static String[] permissions = new String[]{
            Manifest.permission.RECEIVE_BOOT_COMPLETED,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,

            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!arePermissionsGranted()) {
            requestPermissions(permissions, 0);
            checkDelayed();
        } else {
            Log.d("appFlow","Inside Activity_prmission and starting Main activity");
            startMainActivity();
        }
    }

    @Override
    public void onBackPressed() {

    }

    private Boolean arePermissionsGranted(){
        for (String permission : permissions) {
            if (!isPermissionGranted(permission))
                return false;
        }

        return  true;
    }

    private Boolean isPermissionGranted(String permission){
        int res = checkCallingOrSelfPermission(permission);
        return (res == PackageManager.PERMISSION_GRANTED);
    }


    private void checkDelayed(){
        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            public void run() {
                if (arePermissionsGranted())
                    startMainActivity();
                else
                    checkDelayed();
            }
        }, 1000);
    }

    private void startMainActivity() {
        Intent startUpIntent = new Intent(this, Activity_BluetoothStart.class);
        startActivity(startUpIntent);
    }
}
