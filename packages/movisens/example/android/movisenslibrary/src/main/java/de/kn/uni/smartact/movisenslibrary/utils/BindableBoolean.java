package de.kn.uni.smartact.movisenslibrary.utils;

import android.databinding.BaseObservable;

public class BindableBoolean extends BaseObservable {
    boolean mValue;

    public BindableBoolean(Boolean value) {
        set(value);
    }

    public BindableBoolean() {
    }

    public boolean get() {
        return mValue;
    }

    public void set(boolean value) {
        if (mValue != value) {
            this.mValue = value;
            notifyChange();
        }
    }
}