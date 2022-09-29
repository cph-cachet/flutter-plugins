package dk.cachet.movisens_flutter;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.util.Log;

import java.util.HashMap;

import de.kn.uni.smartact.movisenslibrary.screens.viewmodel.Handler_BluetoothStart;

public class PermissionManager {

    private HashMap<String, String> userDataMap;

    private static String[] permissions = new String[] {
            Manifest.permission.BLUETOOTH_CONNECT,
            Manifest.permission.RECEIVE_BOOT_COMPLETED,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };

    private Activity activity;

    public PermissionManager(Activity activity, HashMap<String, String> userDataMap) {
        Log.d("PermissionActivity", userDataMap.toString());
        this.activity = activity;
        this.userDataMap = userDataMap;
    }

    public void startMovisensService() {
        if (!arePermissionsGranted()) {
            activity.requestPermissions(permissions, 0);
            checkDelayed();
        } else {
            startService();
        }
    }

    private Boolean arePermissionsGranted() {
        for (String permission : permissions) {
            if (!isPermissionGranted(permission))
                return false;
        }

        return true;
    }

    private Boolean isPermissionGranted(String permission) {
        int res = activity.checkCallingOrSelfPermission(permission);
        return (res == PackageManager.PERMISSION_GRANTED);
    }

    private void checkDelayed() {
        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            public void run() {
                if (arePermissionsGranted())
                    startService();
                else
                    checkDelayed();
            }
        }, 1000);
    }

    private void startService() {
        Handler_BluetoothStart handler = new Handler_BluetoothStart(activity, userDataMap);
    }
}
