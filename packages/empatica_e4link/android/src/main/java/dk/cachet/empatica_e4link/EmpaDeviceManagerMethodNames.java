package dk.cachet.empatica_e4link;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.SOURCE)
public @interface EmpaDeviceManagerMethodNames {
    String AUTHENTICATE_WITH_API_KEY = "authenticateWithAPIKey";
    String AUTHENTICATE_WITH_CONNECT_USER = "authenticateWithConnectUser";
    String START_SCANNING = "startScanning";
    String STOP_SCANNING = "stopScanning";
    String CONNECT_DEVICE = "connectDevice";
    String SET_DISCOVERED_DEVICES = "setDiscoveredDevices";
    String GET_ACTIVE_DEVICE = "getActiveDevice";
}
