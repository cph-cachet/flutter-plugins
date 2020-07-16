package dk.cachet.background_geolocator.tasks;

import dk.cachet.background_geolocator.data.LocationOptions;

abstract class LocationUsingLocationServicesTask extends Task<LocationOptions> {
    final LocationOptions mLocationOptions;

    LocationUsingLocationServicesTask(TaskContext<LocationOptions> taskContext) {
        super(taskContext);

        mLocationOptions = taskContext.getOptions();
    }
}
