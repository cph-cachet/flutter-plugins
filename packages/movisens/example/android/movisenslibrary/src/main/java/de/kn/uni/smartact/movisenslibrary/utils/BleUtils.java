package de.kn.uni.smartact.movisenslibrary.utils;

import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import java.util.List;
import java.util.UUID;

import de.kn.uni.smartact.movisenslibrary.bluetooth.BLEConnectionHandler;


public class BleUtils {

	private final static String TAG = BleUtils.class.getSimpleName();

	public static boolean hasBluetoothLE(Context context) {
		return (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2 && context
				.getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE));
	}

	public static void enableCharacteristicNotification(UUID enableUuid, String name, List<BluetoothGattCharacteristic> gattCharacteristics, BLEConnectionHandler conncetionHandler) {
		BluetoothGattCharacteristic gattCharacteristic = findCharacteristic(enableUuid, gattCharacteristics);

		if (gattCharacteristic != null) {
			Log.d(TAG, "Enable " + name);
			conncetionHandler.setCharacteristicNotification(gattCharacteristic, true);
		}
	}

	//Function to enable Indication to use buffered Data
	public static void enableCharacteristicIndication(UUID enableUuid, String name, List<BluetoothGattCharacteristic> gattCharacteristics, BLEConnectionHandler conncetionHandler) {
		Log.d(TAG, "Trying to enable indication of " + name);
		BluetoothGattCharacteristic gattCharacteristic = findCharacteristic(enableUuid,gattCharacteristics);

		if(gattCharacteristic != null ) {
			Log.d(TAG, "Enabled indication of " + name);
			conncetionHandler.setCharacteristicIndication(gattCharacteristic, true);
		}
	}

	public static void readCharacteristic(UUID enableUuid, String name, List<BluetoothGattCharacteristic> gattCharacteristics, BLEConnectionHandler conncetionHandler) {
		BluetoothGattCharacteristic gattCharacteristic = findCharacteristic(enableUuid, gattCharacteristics);

		if (gattCharacteristic != null) {
			Log.d(TAG, "Read " + name);
			conncetionHandler.readCharacteristic(gattCharacteristic);
		}
	}

	public static void writeCharacteristic(UUID enableUuid, String name, List<BluetoothGattCharacteristic> gattCharacteristics, BLEConnectionHandler conncetionHandler, byte[] value) {
		BluetoothGattCharacteristic gattCharacteristic = findCharacteristic(enableUuid, gattCharacteristics);

		if (gattCharacteristic != null) {
			Log.d(TAG, "Write " + name);
			gattCharacteristic.setValue(value);
			gattCharacteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
			conncetionHandler.writeCharacteristic(gattCharacteristic);
		}
	}

	public static BluetoothGattCharacteristic findCharacteristic(UUID uuid, List<BluetoothGattCharacteristic> gattCharacteristics) {
		if (gattCharacteristics != null && gattCharacteristics.size() > 0) {
			for (BluetoothGattCharacteristic gattCharacteristic : gattCharacteristics) {
				if (gattCharacteristic != null) {
				    Log.d("gattCharacteristicId ",  gattCharacteristic.getUuid().toString());
					if (gattCharacteristic.getUuid().equals(uuid)) {
                        Log.d("gattCharacteristicName ",  gattCharacteristic.getUuid().toString());
						return gattCharacteristic;
					}
				}
			}
		}
		return null;
	}

	public static BluetoothGattService findService(UUID uuid, List<BluetoothGattService> gattServices) {
		if (gattServices == null)
			return null;

		for (BluetoothGattService gattService : gattServices) {

			if (uuid.equals(gattService.getUuid())) {
                Log.d("uuid_","UUID is "+uuid +"gattService.getUuid() is" +gattService.getUuid());
				return gattService;
			}
		}
		return null;
	}

	final protected static char[] hexArray = "0123456789ABCDEF".toCharArray();

	public static String bytesToHex(byte[] bytes) {
		char[] hexChars = new char[bytes.length * 2];
		for (int j = 0; j < bytes.length; j++) {
			int v = bytes[j] & 0xFF;
			hexChars[j * 2] = hexArray[v >>> 4];
			hexChars[j * 2 + 1] = hexArray[v & 0x0F];
		}
		return new String(hexChars);
	}
}
