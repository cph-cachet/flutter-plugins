package dk.cachet.empatica_e4link;

import com.empatica.empalink.EmpaticaDevice;
import com.empatica.empalink.config.EmpaSensorStatus;
import com.empatica.empalink.config.EmpaSensorType;
import com.empatica.empalink.config.EmpaStatus;
import com.empatica.empalink.delegate.EmpaStatusDelegate;

import io.flutter.plugin.common.MethodChannel.*;

public class EmpaStatusDelegateCallHandler implements EmpaStatusDelegate {
    final MethodChannel channel;


    @Override
    public void didUpdateStatus(EmpaStatus status) {
        channel.invokeMethod("didUpdateStatus", status);
    }

    @Override
    public void didEstablishConnection() {

    }

    @Override
    public void didUpdateSensorStatus(@EmpaSensorStatus int status, EmpaSensorType type) {
        channel.invokeMethod("didUpdateSensorStatus", status, type);
    }

    @Override
    public void didDiscoverDevice(EmpaticaDevice device, String deviceLabel, int rssi, boolean allowed) {
        if (!allowed) return;
        channel.invokeMethod("didDiscoverDevice", device, deviceLabel, rssi);
    }

    @Override
    public void didFailedScanning(int errorCode) {

    }

    @Override
    public void didRequestEnableBluetooth() {

    }

    @Override
    public void bluetoothStateChanged() {

    }

    @Override
    public void didUpdateOnWristStatus(int status) {
        channel.invokeMethod("didUpdateOnWristStatus", status);
    }
}
