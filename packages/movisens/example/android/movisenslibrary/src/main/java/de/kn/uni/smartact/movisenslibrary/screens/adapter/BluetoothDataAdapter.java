package de.kn.uni.smartact.movisenslibrary.screens.adapter;

import android.databinding.DataBindingUtil;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import java.util.List;

import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.databinding.AdapterItemBluetoothDataBinding;
import de.kn.uni.smartact.movisenslibrary.model.BluetoothData;

/**
 * Created by Simon on 06.08.2018.
 */
public class BluetoothDataAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private List<BluetoothData> items;

    public BluetoothDataAdapter(List<BluetoothData> data) {
        super();
        items = data;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        AdapterItemBluetoothDataBinding deaufltBinding = DataBindingUtil.inflate(LayoutInflater.from(parent.getContext()),
                R.layout.adapter_item_bluetooth_data, parent, false);

        return new BluetoothDataHolder(deaufltBinding);
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, final int position) {
        final BluetoothData bluetoothData = items.get(position);

        BluetoothDataHolder bluetoothDataHolder = (BluetoothDataHolder) holder;
        bluetoothDataHolder.getBinding().setBluetoothdata(bluetoothData);
        bluetoothDataHolder.getBinding().executePendingBindings();
    }

    private class BluetoothDataHolder extends RecyclerView.ViewHolder {

        AdapterItemBluetoothDataBinding _binding;

        public BluetoothDataHolder(AdapterItemBluetoothDataBinding binding) {
            super(binding.getRoot());

            this._binding = binding;
        }

        public AdapterItemBluetoothDataBinding getBinding() {
            return this._binding;
        }
    }
}
