package de.kn.uni.smartact.movisenslibrary.utils;

import android.annotation.TargetApi;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.os.Build;
import android.util.Log;

import java.util.LinkedList;
import java.util.Queue;

/**
 * Required Queue to serialize GATT commands
 * 
 */
@TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
public class BleQueue {
	enum ActionType {
		writeDescriptor, readCharacteristic, writeCharacteristic
	}

	private Queue<Action> bleQueue = new LinkedList<Action>();
	private BluetoothGatt mBluetoothGatt;

	public BleQueue(BluetoothGatt bluetoothGatt) {
		this.mBluetoothGatt = bluetoothGatt;
	}

	public void writeDescriptor(BluetoothGattDescriptor descriptor) {
		addAction(ActionType.writeDescriptor, descriptor);
	}

	public void onDescriptorWrite(BluetoothGatt gatt,
			BluetoothGattDescriptor descriptor, int status) {
		bleQueue.remove();
		nextAction();
	};

	public void readCharacteristic(BluetoothGattCharacteristic characteristic) {
		addAction(ActionType.readCharacteristic, characteristic);
	}

	public void onCharacteristicRead(BluetoothGatt gatt,
			BluetoothGattCharacteristic characteristic, int status) {
		bleQueue.remove();
		nextAction();
	}

	public void writeCharacteristic(BluetoothGattCharacteristic characteristic) {
		addAction(ActionType.writeCharacteristic, characteristic);
	}

	public void onCharacteristicWrite(BluetoothGatt gatt,
			BluetoothGattCharacteristic characteristic, int status) {
		bleQueue.remove();
		nextAction();
	}

	private void addAction(ActionType actionType, Object object) {
		bleQueue.add(new Action(actionType, object));
		// if there is only 1 item in the queue, then process it. If more than
		// 1,
		// we handle asynchronously in the callback.
		if (bleQueue.size() == 1)
			nextAction();
	}

	private void nextAction() {
		if (bleQueue.isEmpty())
			return;
		Action action = bleQueue.element();
		if (ActionType.writeDescriptor.equals(action.getType())) {
			mBluetoothGatt.writeDescriptor((BluetoothGattDescriptor) action
					.getObject());
		} else if (ActionType.writeCharacteristic.equals(action.getType())) {
			mBluetoothGatt
					.writeCharacteristic((BluetoothGattCharacteristic) action
							.getObject());
		} else if (ActionType.readCharacteristic.equals(action.getType())) {
			mBluetoothGatt
					.readCharacteristic((BluetoothGattCharacteristic) action
							.getObject());
		} else {
			Log.e("BLEQueue", "Undefined Action found");
		}
	}

	public class Action {
		private final ActionType actionType;
		private final Object object;

		public Action(ActionType actionType, Object object) {
			this.actionType = actionType;
			this.object = object;
		}

		public ActionType getType() {
			return this.actionType;
		}

		public Object getObject() {
			return this.object;
		}
	}
}
