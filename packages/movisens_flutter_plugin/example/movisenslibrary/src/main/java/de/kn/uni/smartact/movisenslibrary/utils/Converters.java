package de.kn.uni.smartact.movisenslibrary.utils;

import android.databinding.BindingAdapter;
import android.databinding.BindingConversion;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;

import java.util.Arrays;

import de.kn.uni.smartact.movisenslibrary.R;


public class Converters {

    public static final String START = "start";
    public static final String STOP = "stop";
    public static final String RESET = "reset";

    @BindingConversion
    public static String convertBindableToString(BindableString bindableString) {
        return bindableString.get();
    }


    @BindingAdapter({"binding"})
    public static void bindRadioGroup(RadioGroup view, final BindableString bindableString) {
        if (view.getTag(R.id.bound_observable) != bindableString) {
            view.setTag(R.id.bound_observable, bindableString);
            view.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(RadioGroup group, int checkedId) {
                    for (int i = 0; i < group.getChildCount(); i++) {
                        final View child = group.getChildAt(i);
                        if (checkedId == child.getId()) {
                            bindableString.set(child.getTag().toString());
                            break;
                        }
                    }
                }
            });
        }
        String newValue = bindableString.get();
        for (int i = 0; i < view.getChildCount(); i++) {
            final View child = view.getChildAt(i);
            if (child instanceof RadioButton && newValue.equals(child.getTag())) {
                ((RadioButton) child).setChecked(true);
                break;
            }
        }
    }

    @BindingAdapter("bindingOneWay")
    public static void bindSpinner(Spinner view, final BindableString bindableString) {

        if (view.getTag(R.id.bound_observable) != bindableString) {
            view.setTag(R.id.bound_observable, bindableString);

            String[] entries = view.getResources().getStringArray(R.array.sensor_positions);
            int index = Arrays.asList(entries).indexOf(bindableString.get());
            if (index != -1)
                view.setSelection(index);

            view.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                    bindableString.set(((TextView)view).getText().toString());
                }

                @Override
                public void onNothingSelected(AdapterView<?> parent) {
                    bindableString.set("");
                }
            });
        }
    }



    @BindingAdapter("binding")
    public static void nameChanged(EditText editText, final BindableString bindableString) {
        if (editText.getTag(R.id.bound_observable) != bindableString) {

            //detach old object
            if ((editText.getTag(R.id.bound_observable) != null) && (editText.getTag(R.id.bound_observable) instanceof BindableString)) {
                BindableString oldBinding = (BindableString) editText.getTag(R.id.bound_observable);
                editText.removeTextChangedListener(oldBinding.getWatcher());
                oldBinding.setWatcher(null);
            }

            //attach new object
            editText.setTag(R.id.bound_observable, bindableString);
            bindableString.setWatcher(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                }

                @Override
                public void afterTextChanged(Editable s) {
                    if (bindableString.getWatcher() == this) {
                        bindableString.set(s.toString());
                    }
                }
            });
            editText.addTextChangedListener(bindableString.getWatcher());

        } else {
            editText.setSelection(editText.getText().length());
        }
    }



    @BindingAdapter({"onClick"})
    public static void bindOnClick(View view, final Runnable runnable) {
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                runnable.run();
            }
        });
    }
}
