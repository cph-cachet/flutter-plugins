package de.kn.uni.smartact.movisenslibrary.screens;

import android.app.Activity;
import android.content.DialogInterface;
import android.os.Bundle;

import de.kn.uni.smartact.movisenslibrary.R;

public class NoMeasurmentDialog extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        android.app.AlertDialog.Builder alertDialogBuilder = new android.app.AlertDialog.Builder(this);
        alertDialogBuilder.setMessage(getString(R.string.no_running_messurment));
        alertDialogBuilder
                .setCancelable(false)
                .setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        finish();
                    }
                });

        android.app.AlertDialog alertDialog = alertDialogBuilder.create();
        alertDialog.show();

    }
}