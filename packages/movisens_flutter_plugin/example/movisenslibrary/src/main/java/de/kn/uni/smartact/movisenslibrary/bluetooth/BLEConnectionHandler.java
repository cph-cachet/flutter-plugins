/*
 * Copyright (C) 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package de.kn.uni.smartact.movisenslibrary.bluetooth;

import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.content.Intent;
import android.os.ParcelUuid;
import android.util.Log;

import com.movisens.smartgattlib.descriptors.ClientCharacteristicConfiguration;

import java.lang.reflect.Method;
import java.util.Date;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import de.kn.uni.smartact.movisenslibrary.utils.BleQueue;
import de.kn.uni.smartact.movisenslibrary.utils.BleUtils;

/**
 * Service for managing connection and data communication with a GATT server
 * hosted on a given Bluetooth LE device.
 */
public class BLEConnectionHandler {
	private final static String TAG = BLEConnectionHandler.class.getSimpleName();

	private static final long MIN_RECONNECT_DELAY = 30000;


	private BluetoothManager mBluetoothManager;
	private BluetoothAdapter mBluetoothAdapter;
	private String mBluetoothDeviceAddress;
	private BluetoothGatt mBluetoothGatt;
	private int mConnectionState = STATE_DISCONNECTED;
	private BleQueue bleQueue;

	private static final int STATE_DISCONNECTED = 0;
	private static final int STATE_CONNECTING = 1;
	private static final int STATE_CONNECTED = 2;

	public final static String ACTION_GATT_CONNECTED = "com.movisens.rmssdtrigger.services.BluetoothLeService.ACTION_GATT_CONNECTED";
	public final static String ACTION_GATT_DISCONNECTED = "com.movisens.rmssdtrigger.services.BluetoothLeService.ACTION_GATT_DISCONNECTED";
	public final static String ACTION_GATT_SERVICES_DISCOVERED = "com.movisens.rmssdtrigger.services.BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED";
	public final static String ACTION_DATA_AVAILABLE = "com.movisens.rmssdtrigger.services.BluetoothLeService.ACTION_DATA_AVAILABLE";
	public final static String EXTRA_DATA = "com.movisens.rmssdtrigger.services.BluetoothLeService.EXTRA_DATA";
	public final static String EXTRA_CHARACTERISTIC = "com.movisens.rmssdtrigger.services.BluetoothLeService.EXTRA_CHARACTERISTIC";
	public final static String ACTION_GATT_SERVICES_ERROR = "com.movisens.rmssdtrigger.services.BluetoothLeService.GATT_SERVICES_ERROR";

	public final static String ACTION_LOG = "com.movisens.rmssdtrigger.services.BluetoothLeService.LOG";
	public final static String EXTRA_TAG = "com.movisens.rmssdtrigger.services.BluetoothLeService.EXTRA_TAG";
	public final static String EXTRA_MESSAGE = "com.movisens.rmssdtrigger.services.BluetoothLeService.EXTRA_MESSAGE";

	private Service mContext;
	private String mDeviceAdress;
	long mLastReconnect;

	private ScheduledThreadPoolExecutor mScheduler;
	private ScheduledFuture mPendingReconnect;

	public BLEConnectionHandler(Service context){
		this.mContext = context;

		///mReconnectHandler = new Handler(Looper.getMainLooper());
		mLastReconnect = new Date().getTime();

		mScheduler = (ScheduledThreadPoolExecutor) Executors.newScheduledThreadPool(1);
	}

	/**
	 * Initializes a reference to the local Bluetooth adapter.
	 *
	 * @return Return true if the initialization is successful.
	 */
	public boolean initialize() {
		if (!BleUtils.hasBluetoothLE(mContext)) {
			log(TAG, "Bluetooth Low Energy is not supported on this phone.");
			return false;
		}

		mBluetoothManager = (BluetoothManager) mContext.getSystemService(Context.BLUETOOTH_SERVICE);
		if (mBluetoothManager == null) {
			log(TAG, "Unable to initialize BluetoothManager.");
			return false;
		}

		mBluetoothAdapter = mBluetoothManager.getAdapter();
		if (mBluetoothAdapter == null) {
			log(TAG, "Unable to obtain a BluetoothAdapter.");
			return false;
		}

		setBluetooth(true);
		return true;
	}

	public String setDevice(String address) {
		mDeviceAdress = address;

		if(!address.equals("")) {
			BluetoothDevice remoteDevice = mBluetoothAdapter.getRemoteDevice(address);

			if (remoteDevice != null) {

				if (remoteDevice.getBondState() == BluetoothDevice.BOND_BONDED) {
					unpairDevice(remoteDevice);
					log(TAG, "BondState: BOND_BONDED");
				} else if (remoteDevice.getBondState() == BluetoothDevice.BOND_BONDING) {
					unpairDevice(remoteDevice);
					log(TAG, "BondState: BOND_BONDING");
				}

				log(TAG, "Initiate connect device");
				connect(remoteDevice.getAddress());

				return remoteDevice.getName();
			}
		}

		return null;
	}

	private void unpairDevice(BluetoothDevice device) {
		try {
			Method m = device.getClass().getMethod("removeBond", (Class[]) null);
			m.invoke(device, (Object[]) null);
		} catch (Exception e) {
			log(TAG, "Unbound: " + e.getMessage());
		}
	}

	public void reconnectDelayed() {
		if (mPendingReconnect != null && !mPendingReconnect.isDone())
			mPendingReconnect.cancel(true);

		long milisecondsdelay = 0;
		long timeSinceReconnect = new Date().getTime() - mLastReconnect;

		if (timeSinceReconnect < MIN_RECONNECT_DELAY) {
			milisecondsdelay = MIN_RECONNECT_DELAY - timeSinceReconnect;
		}

		Log.d(TAG, "Reconnect in " + milisecondsdelay + " ms");

		mPendingReconnect = mScheduler.schedule(
				new Runnable() {
					@Override
					public void run() {
						mLastReconnect = new Date().getTime();
						try {
							log(TAG, "Trying to reconnect");
							setDevice(mDeviceAdress);
						} catch (NullPointerException e) {
							log(TAG,"No Sensor connected");
						}
					}
				}
				, milisecondsdelay, TimeUnit.MILLISECONDS);
	}



	// Implements callback methods for GATT events that the app cares about. For
	// example, connection change and services discovered.
	private final BluetoothGattCallback mGattCallback = new BluetoothGattCallback() {

		@Override
		public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
			if (mPendingReconnect != null && !mPendingReconnect.isDone())
				mPendingReconnect.cancel(true);

			String intentAction;
			if (status == BluetoothGatt.GATT_SUCCESS) {
				if (newState == BluetoothProfile.STATE_CONNECTED) {
					intentAction = ACTION_GATT_CONNECTED;
					mConnectionState = STATE_CONNECTED;
					broadcastUpdate(intentAction);
					log(TAG, "Connected to GATT server.");
					// Attempts to discover services after successful connection.
					log(TAG, "Attempting to start service discovery:" + gatt.discoverServices());

				} else {
					if (newState == BluetoothProfile.STATE_DISCONNECTED) {
						intentAction = ACTION_GATT_DISCONNECTED;
						mConnectionState = STATE_DISCONNECTED;
						log(TAG, "Disconnected from GATT server.");
						broadcastUpdate(intentAction);

						close();
					}
				}

			} else {
				close();

				intentAction = ACTION_GATT_SERVICES_ERROR;
				mConnectionState = STATE_DISCONNECTED;
				log(TAG, "Gatt server error, status: " + status + ", newState: " + newState);
				broadcastUpdate(intentAction);
			}
		}

		@Override
		public void onServicesDiscovered(BluetoothGatt gatt, int status) {
			if (status == BluetoothGatt.GATT_SUCCESS) {
				broadcastUpdate(ACTION_GATT_SERVICES_DISCOVERED);
			}

			log(TAG, "onServicesDiscovered received: " + status);
		}

		@Override
		public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
			bleQueue.onCharacteristicRead(gatt, characteristic, status);
			if (status == BluetoothGatt.GATT_SUCCESS) {
				broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);
			}

			log(TAG, "onServicesDiscovered received: " + status);
		}

		@Override
		public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
			bleQueue.onCharacteristicWrite(gatt, characteristic, status);
			if (status == BluetoothGatt.GATT_SUCCESS) {
				log(TAG, "Characteristic writing successful");
			} else if (status == BluetoothGatt.GATT_INSUFFICIENT_AUTHENTICATION) {
				// this is where the tricky part comes

				if (gatt.getDevice().getBondState() == BluetoothDevice.BOND_NONE) {
					log(TAG, "Bonding required!!!");
				} else {
					// this situation happens when you try to connect for the second time to already bonded device it should never happen, in my opinion
					log(TAG,"The phone is trying to read from paired device without encryption. Android Bug?");
					// I don't know what to do here. This error was found on Nexus 7 with KRT16S build of Andorid 4.4. It does not appear on Samsung S4 with Andorid 4.3.
				}
			} else {
				log(TAG, "Error writing characteristic, status: " + status + "Characteristic: " + characteristic.getUuid());
			}
		}

		@Override
		public void onDescriptorWrite(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
			if (status == BluetoothGatt.GATT_SUCCESS) {
				log(TAG, "Discriptor writing successful");
			} else if (status == BluetoothGatt.GATT_INSUFFICIENT_AUTHENTICATION) {
				// this is where the tricky part comes

				if (gatt.getDevice().getBondState() == BluetoothDevice.BOND_NONE) {
					log(TAG, "Bonding required!!!");
				} else {
					// this situation happens when you try to connect for the second time to already bonded device it should never happen, in my opinion
					log(TAG, "The phone is trying to read from paired device without encryption. Android Bug?");
					// I don't know what to do here This error was found on Nexus 7 with KRT16S build of Andorid 4.4. It does not appear on Samsung S4 with Andorid 4.3.
				}
			} else {
				log(TAG, "Error writing descriptor, status: " + status + "Descriptor: " + descriptor.getUuid());
			}
			bleQueue.onDescriptorWrite(gatt, descriptor, status);
		};

		@Override
		public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
			broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);
			log(TAG, "Data available");
		}
	};




	private void broadcastLog(String tag, String message) {
		final Intent intent = new Intent(ACTION_LOG);
		intent.putExtra(EXTRA_TAG, tag);
		intent.putExtra(EXTRA_MESSAGE, message);
		mContext.sendBroadcast(intent);
	}

	private void broadcastUpdate(final String action) {
		final Intent intent = new Intent(action);
		mContext.sendBroadcast(intent);
	}

	private void broadcastUpdate(final String action, final BluetoothGattCharacteristic characteristic) {
		final Intent intent = new Intent(action);
		intent.putExtra(EXTRA_DATA, characteristic.getValue());
		intent.putExtra(EXTRA_CHARACTERISTIC, new ParcelUuid(characteristic.getUuid()));
		mContext.sendBroadcast(intent);
	}



	/**
	 * Connects to the GATT server hosted on the Bluetooth LE device.
	 *
	 * @param address
	 *            The device address of the destination device.
	 *
	 * @return Return true if the connection is initiated successfully. The
	 *         connection result is reported asynchronously through the
	 *         {@code BluetoothGattCallback#onConnectionStateChange(android.bluetooth.BluetoothGatt, int, int)}
	 *         callback.
	 */
	public boolean connect(final String address) {
		if (mBluetoothAdapter == null || address == null) {
			log(TAG,"BluetoothAdapter not initialized or unspecified address.");
			return false;
		}

		// Previously connected device. Try to reconnect.
		 if (mBluetoothDeviceAddress != null && address.equals(mBluetoothDeviceAddress) && mBluetoothGatt != null) {
		 	log(TAG,"Trying to use an existing mBluetoothGatt for connection.");
		 	if (mBluetoothGatt.connect()) {
		 		mConnectionState = STATE_CONNECTING;
				return true;
		 	} else {
				return false;
			}
		}

		if (mBluetoothDeviceAddress != null && !address.equals(mBluetoothDeviceAddress) && mBluetoothGatt != null) {
			log(TAG, "Clearing out existing connection");
			close();
		}

		final BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(address);

		if (device == null) {
			log(TAG, "Device not found. Unable to connect.");
			return false;
		}

		// We want to directly connect to the device, so we are setting the
		// autoConnect parameter to false.
		mBluetoothGatt = device.connectGatt(mContext, false, mGattCallback, BluetoothDevice.TRANSPORT_LE);
		//clear cache so that the next connection does not realey on cached data
		Boolean result = refreshDeviceCache(mBluetoothGatt);
		bleQueue = new BleQueue(mBluetoothGatt);
		log(TAG, "Trying to create a new connection.");
		mBluetoothDeviceAddress = address;
		mConnectionState = STATE_CONNECTING;
		return true;
	}

	private boolean refreshDeviceCache(BluetoothGatt gatt){
		try {
			BluetoothGatt localBluetoothGatt = gatt;
			Method localMethod = localBluetoothGatt.getClass().getMethod("refresh", new Class[0]);
			if (localMethod != null) {
				boolean bool = ((Boolean) localMethod.invoke(localBluetoothGatt, new Object[0])).booleanValue();
				log(TAG, "Bluetoth Device refreshing successful: " + bool);
				return bool;
			}
		}
		catch (Exception localException) {
			log(TAG, "An exception occurred while refreshing bluetooth device");
		}
		return false;
	}



	/**
	 * After using a given BLE device, the app must call this method to ensure
	 * resources are released properly.
	 */
	public void close() {
		if (mBluetoothGatt == null) {
			log(TAG, "Try to close but BluetoothGatt not properly connected");
			return;
		}
		// Necessary to disconnect and close because of Android bug:
		// https://code.google.com/p/android/issues/detail?id=58381#c17
		// http://stackoverflow.com/a/18889509/2616544

		//mBluetoothGatt.disconnect();

		mBluetoothGatt.close();
		mBluetoothGatt = null;
	}

	/**
	 * Request a read on a given {@code BluetoothGattCharacteristic}. The read
	 * result is reported asynchronously through the
	 * {@code BluetoothGattCallback#onCharacteristicRead(android.bluetooth.BluetoothGatt, android.bluetooth.BluetoothGattCharacteristic, int)}
	 * callback.
	 *
	 * @param characteristic
	 *            The characteristic to read from.
	 */
	public void readCharacteristic(BluetoothGattCharacteristic characteristic) {
		if (mBluetoothAdapter == null || mBluetoothGatt == null) {
			log(TAG, "BluetoothAdapter not initialized");
			return;
		}
		bleQueue.readCharacteristic(characteristic);
	}

	/**
	 * Request a read on a given {@code BluetoothGattCharacteristic}. The read
	 * result is reported asynchronously through the
	 * {@code BluetoothGattCallback#onCharacteristicRead(android.bluetooth.BluetoothGatt, android.bluetooth.BluetoothGattCharacteristic, int)}
	 * callback.
	 *
	 * @param characteristic
	 *            The characteristic to read from.
	 */
	public void writeCharacteristic(BluetoothGattCharacteristic characteristic) {
		if (mBluetoothAdapter == null || mBluetoothGatt == null) {
			log(TAG, "BluetoothAdapter not initialized");
			return;
		}
		bleQueue.writeCharacteristic(characteristic);
	}

	/**
	 * Enables or disables notification on a give characteristic.
	 * 	 * 	 *
	 * @param characteristic
	 *            Characteristic to act on.
	 * @param enabled
	 *            If true, enable notification. False otherwise.
	 */
	public void setCharacteristicNotification(BluetoothGattCharacteristic characteristic, boolean enabled) {
		if (mBluetoothAdapter == null || mBluetoothGatt == null) {
			log(TAG, "BluetoothAdapter not initialized");
			return;
		}
		mBluetoothGatt.setCharacteristicNotification(characteristic, enabled);

		// Is this specific to Heart Rate Measurement?
		BluetoothGattDescriptor descriptor = characteristic.getDescriptor(ClientCharacteristicConfiguration.uuid);
		if (descriptor != null) {
			descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
			bleQueue.writeDescriptor(descriptor);
		}
	}

	/**
	 * Enables or disables notification on a give characteristic.
	 *
	 * @param characteristic
	 *            Characteristic to act on.
	 * @param enabled
	 *            If true, enable notification. False otherwise.
	 */
	public void setCharacteristicIndication(BluetoothGattCharacteristic characteristic, boolean enabled) {
		if (mBluetoothAdapter == null || mBluetoothGatt == null) {
			log(TAG, "BluetoothAdapter not initialized");
			return;
		}
		mBluetoothGatt.setCharacteristicNotification(characteristic, enabled);

		// Is this specific to Heart Rate Measurement?
		BluetoothGattDescriptor descriptor = characteristic.getDescriptor(ClientCharacteristicConfiguration.uuid);
		if (descriptor != null) {
			descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE);
			bleQueue.writeDescriptor(descriptor);
		}
	}

	/**
	 * Retrieves a list of supported GATT services on the connected device. This
	 * should be invoked only after {@code BluetoothGatt#discoverServices()}
	 * completes successfully.
	 *
	 * @return A {@code List} of supported services.
	 */
	public List<BluetoothGattService> getSupportedGattServices() {
		if (mBluetoothGatt == null)
			return null;

		return mBluetoothGatt.getServices();
	}

	public boolean isConnected() {
		return mConnectionState == STATE_CONNECTED;
	}


	public boolean setBluetooth(boolean enable) {
		boolean isEnabled = mBluetoothAdapter.isEnabled();

		if (enable && !isEnabled) {
			return mBluetoothAdapter.enable();
		} else if (!enable && isEnabled) {
			return mBluetoothAdapter.disable();
		}
		// No need to change bluetooth state
		return true;
	}



	public void log(String tag, String message) {
		broadcastLog(tag, message);
	}

}
