package de.kn.uni.smartact.movisenslibrary.events;

public class MeasurementStatus { 
	public enum SensorState {
		Unknown, True, False
	};

	public SensorState measurementEnabled = SensorState.Unknown;
	public SensorState dataAvailable = SensorState.Unknown;
}