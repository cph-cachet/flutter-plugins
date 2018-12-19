package de.kn.uni.smartact.movisenslibrary.events;

public class SensorStatusEvent {
	public enum SensorStatus {
		Connected, Disconnected
	};

	private SensorStatus mStatus = SensorStatus.Disconnected;

	public SensorStatus getStatus() {
		return mStatus;
	}

	public SensorStatusEvent(SensorStatus status) {
		mStatus = status;
	}
}
