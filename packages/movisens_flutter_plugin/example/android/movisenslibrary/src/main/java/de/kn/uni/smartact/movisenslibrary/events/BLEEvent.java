package de.kn.uni.smartact.movisenslibrary.events;

public class BLEEvent {

	private String mMessage = "";

	public String getMessage() {
		return mMessage;
	}

	public BLEEvent(String message) {
		mMessage = message;
	}

}
