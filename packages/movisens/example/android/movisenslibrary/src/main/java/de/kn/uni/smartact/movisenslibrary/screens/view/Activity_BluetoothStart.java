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

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.SensorApplication;
import de.kn.uni.smartact.movisenslibrary.databinding.ActivityBluetoothStartBinding;
import de.kn.uni.smartact.movisenslibrary.screens.viewmodel.Handler_BluetoothStart;


public class Activity_BluetoothStart extends AppCompatActivity {

    private boolean isPwPromptActive = false;
    private Handler_BluetoothStart handler;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d("appFlow","Step 2:  Inside Activity_BluetoothStart On create");

        handler = new Handler_BluetoothStart(this);

        ActivityBluetoothStartBinding binding = DataBindingUtil.setContentView(this, R.layout.activity_bluetooth_start);

        binding.setHandler(handler);
    }



    @Override
    protected void onResume() {
        super.onResume();

        handler.updateButtonEnabled();
        askForPassword();
    }

    @Override
    public void onBackPressed() {

    }

    private void askForPassword() {
        if (SensorApplication.isLoggedIn || isPwPromptActive) {
            return;
        }

        isPwPromptActive = true;

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(getString(R.string.enter_password));

        final Activity activity = this;
        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        builder.setView(input);
        builder.setCancelable(false);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                String pw = input.getText().toString();

                if (isPasswordCorrect(pw)) {
                    SensorApplication.isLoggedIn = true;
                } else {
                    Toast.makeText(activity, getString(R.string.wrong_password), Toast.LENGTH_LONG).show();
                    activity.finishAffinity();
                }

                isPwPromptActive = false;
            }
        });

        Dialog dialog = builder.create();
        dialog.show();

        // force show keyboard
        dialog.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE|WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
        dialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
    }


    private boolean isPasswordCorrect(String pw) {
        // Months start at 0 in java ...
        int month = Calendar.getInstance().get(Calendar.MONTH) + 1;
        // Days start at 1 in java ...
        int day = Calendar.getInstance().get(Calendar.DAY_OF_MONTH);

        return pw != null && pw.contains(Integer.toString(month + (day * 2)));
    }
}
