package de.kn.uni.smartact.movisenslibrary.screens.adapter;

import android.databinding.DataBindingUtil;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import java.util.List;
import de.kn.uni.smartact.movisenslibrary.R;
import de.kn.uni.smartact.movisenslibrary.databinding.AdapterItemBluetoothDeviceBinding;

/**
 * Created by Simon on 06.08.2018.
 */
public class BluetoothDeviceAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private List<BluetoothDeviceHandler> items;

    public BluetoothDeviceAdapter(List<BluetoothDeviceHandler> data) {
        super();
        items = data;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        AdapterItemBluetoothDeviceBinding deaufltBinding =
                DataBindingUtil.inflate(LayoutInflater.from(parent.getContext()),
                R.layout.adapter_item_bluetooth_device, parent, false);

        return new DeviceHolder(deaufltBinding);
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, final int position) {
        final BluetoothDeviceHandler deviceHandler = items.get(position);

        DeviceHolder deviceHolder = (DeviceHolder) holder;
        deviceHolder.getBinding().setDeviceHandler(deviceHandler);
        deviceHolder.getBinding().executePendingBindings();
    }

    private class DeviceHolder extends RecyclerView.ViewHolder {

        AdapterItemBluetoothDeviceBinding _binding;

        public DeviceHolder(AdapterItemBluetoothDeviceBinding binding) {
            super(binding.getRoot());

            this._binding = binding;
        }

        public AdapterItemBluetoothDeviceBinding getBinding() {
            return this._binding;
        }
    }
}
