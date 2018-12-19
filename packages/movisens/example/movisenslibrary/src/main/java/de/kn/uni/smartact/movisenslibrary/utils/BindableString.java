package de.kn.uni.smartact.movisenslibrary.utils;

import android.databinding.BaseObservable;
import android.text.TextWatcher;

import java.util.Objects;

public class BindableString extends BaseObservable {

    private StringUpdateListener _listener;
    private TextWatcher _watcher;

    private String _value;

    public BindableString() {
        set("");
    }

    public BindableString(String _string) {
        set(_string);
    }

    public TextWatcher getWatcher() {
        return _watcher;
    }

    public void setWatcher(TextWatcher watcher) {
        _watcher = watcher;
    }

    public void setUpdateListener(StringUpdateListener listener) {
        _listener = listener;
    }

    public String get() {
        return _value != null ? _value : "";
    }

    public void set(String value) {
        if (!Objects.equals(this._value, value)) {
            this._value = value;
            if (_listener != null) {
                _listener.onUpdate(value);
            }
            notifyChange();
        }
    }

    public boolean isEmpty() {
        return _value == null || _value.isEmpty();
    }

    public interface StringUpdateListener {
        void onUpdate(String value);
    }
}