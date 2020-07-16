package dk.cachet.background_geolocator.tasks;

import android.location.Location;
import android.location.LocationManager;

import dk.cachet.background_geolocator.data.LocationOptions;
import dk.cachet.background_geolocator.data.PositionMapper;
import dk.cachet.background_geolocator.data.wrapper.ChannelResponse;

class LastKnownLocationUsingLocationManagerTask extends LocationUsingLocationManagerTask {

  LastKnownLocationUsingLocationManagerTask(TaskContext<LocationOptions> context) {
    super(context);
  }

  @Override
  public void startTask() {
    LocationManager locationManager = getLocationManager();

    Location bestLocation = null;

    for (String provider : locationManager.getProviders(true)) {
      Location location = locationManager.getLastKnownLocation(provider);

      if (location != null && isBetterLocation(location, bestLocation)) {
        bestLocation = location;
      }
    }

    ChannelResponse channelResponse = getTaskContext().getResult();
    if (bestLocation == null) {
      channelResponse.success(null);
      stopTask();
      return;
    }

    channelResponse.success(PositionMapper.toHashMap(bestLocation));
    stopTask();
  }
}
