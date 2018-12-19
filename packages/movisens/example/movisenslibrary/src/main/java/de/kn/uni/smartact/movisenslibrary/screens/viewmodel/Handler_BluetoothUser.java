package de.kn.uni.smartact.movisenslibrary.screens.viewmodel;

import android.app.Activity;
import android.widget.Toast;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.model.UserData;

public class Handler_BluetoothUser {

    Activity context;

    UserData userData;

    public Handler_BluetoothUser(Activity context) {
        this.context = context;

        userData = new UserData(context);
    }

    public UserData getUserData() {
        return userData;
    }

    public void saveAndContinue(){


        if (userData.age.get().equals("") || Integer.valueOf(userData.age.get()) < 0 || Integer.valueOf(userData.age.get()) > 200) {
            CharSequence text = context.getResources().getString(R.string.age_range);
            int duration = Toast.LENGTH_LONG;
            Toast toast = Toast.makeText(context.getApplicationContext(), text, duration);
            toast.show();
            return;
        }

        if (userData.weight.get().equals("") || Integer.valueOf(userData.weight.get()) < 0 || Integer.valueOf(userData.weight.get()) > 300) {
            CharSequence text = context.getResources().getString(R.string.weight_range);
            int duration = Toast.LENGTH_LONG;
            Toast toast = Toast.makeText(context.getApplicationContext(), text, duration);
            toast.show();
            return;
        }

        if (userData.height.get().equals("") || Integer.valueOf(userData.height.get()) < 0 || Integer.valueOf(userData.height.get()) > 300) {
            CharSequence text = context.getResources().getString(R.string.height_range);
            int duration = Toast.LENGTH_LONG;
            Toast toast = Toast.makeText(context.getApplicationContext(), text, duration);
            toast.show();
            return;
        }

        userData.saveToDB(context);
        context.finish();
    }


}


