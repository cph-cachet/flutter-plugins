# Mobility Features
Author: Thomas Nilsson (tnni@dtu.dk)

## Usage

### Step 0: Get the package

Add the package to your `pubspec.yaml` file and import the package

```dart
import 'package:mobility_features/mobility_features.dart';
```

### Step 1: Collect location data
Location data collection is not directly supported by this package, for this you have to use a location plugin such as `https://pub.dev/packages/geolocator`. 

From here, you can to convert from whichever Data Transfer Object is used 
by the location plugin to a `LocationSample`. 

Below is shown an example using the `geolocator` plugin, where a `Position` stream is converted into a `LocationSample` stream by using a map-function.

```dart
List<LocationSample> locationSamples = [];
...
void setUpLocationStream() {
  // Set up a Position stream, and make it into a broadcast stream
  Stream<Position> positionStream =
    Geolocator().getPositionStream().asBroadcastStream(); 

  // Convert the Position stream into a LocationSample stream
  Stream<LocationSample> locationSampleStream = positionStream.map((e) =>
    LocationSample(GeoPosition(e.latitude, e.longitude), e.timestamp));

  // Make the Mobility Factory start listening to location updates
  mobilityFactory.startListening(locationSampleStream);
}
```

### Step 2: Save location data
The location data must be saved on the device such that it can be used in the future. 

Saving the data to persistent storage also prevents it from being lost should the app be shut down.

Given that the location samples have been collected in a list `List<LocationSample> locationSamples` the data is serialized like so:

```dart
await ContextGenerator.saveSamples(locationSamples);
```

Ideally, saving the data is done with a certain interval, such as every time 100 `LocationSamples` are collected. 

### Step 3: Compute features
The features can be computed using the `ContextGenerator` which uses stored data to compute the features.

There most basic computation is done as follows:

```dart
MobilityContext context = await ContextGenerator.generate();
```

All features are implemented as getters for the `MobilityContext` object.

```dart
context.places;
context.stops;
context.moves;

context.numberOfPlaces;
context.homeStay;
context.entropy;
context.normalizedEntropy;
context.distanceTravelled;
context.routineIndex;
```

Note: it is not possible to instantiate a `MobilityContext` object directly. 
It must be intantiated through the `ContextGenerator.generate()` method.

#### Step 3.1 : Compute features with prior contexts
Should you wish to compute the Routine Index feature (see Theoretical Background) as well, then prior contexts are needed. 

Concretely, you will have to track for at least 2 days, to compute this feature.

The computation using prior contexts is done as follows

```dart
 
```

#### Step 3.2: Compute features for a specific date
By default, the `MobilityContext` object uses the current date as reference to filter 
and group data, however, should you wish to compute the features for 
a specific date, then it is possible to do so using the `today` parameter.

```dart
DateTime myDate = DateTime(01, 01, 2020);
MobilityContext context = await ContextGenerator.generate(today: myDate);
```

### Feature-specific instructions
When a feature cannot be evaluated, it will result in a value of -1.0.

The Home Stay feature requires at least *some* data to be collected between 00:00 and 06:00, otherwise the feature cannot be evaluated. 

The Routine Index feature requires at least two days of sufficient data to be evaulated.

The Entropy and Normalized Entropy features require at least 2 places 
to be evaluated. If only a single place was found, 
the feature can technically still be evaluated and 
will result in an Entropy of 0, as per the definition of Entropy. 

## Theorical Background
For mental health research, location data, together with a time component, 
both collected from the user’s smartphone, can be reduced to certain behavioral 
features pertaining to the user’s mobility. 
These features can be used to diagnose patients suffering from mental disorders such as depression. 

Previously, mobility recognition has been done in an off-device fashion where features are extracted 
after a study was completed. We propose performing mobility feature extracting in real-time on the device 
itself, as new data comes in a continuous fashion. This trades compute power, i.e. 
phone battery for bandwidth and storage since the reduced features take up much less space than the raw GPS data, 
and transforms the very intrusive GPS data to abstract features, which avoids unnecessary logging of sensitive data.

### Location Features
The mobility features which will be used are derived from GPS location data are:

**Stop**
A collection of GPS points which together represent a visit at a known \texit{Place} (see below) for an extended period of time. A \textit{Stop} is defined by a location that represents the centroid of a collection of data points, from which a \textit{Stop} is created. In addition a \textit{Stop} also has an \textit{arrival}- and a \textit{departure} time-stamp, representing when the user arrived at the place and when the user left the place. From the arrival- and departure timestamps of the \textit{Stop} the duration can be computed.

**Place**
A group of stops that were clustered by the DBSCAN algorithm \cite{density-based-1996}. From the cluster of stops, the centroid of the stops can be found, i.e. the center location. In addition, it can be computed how long a user has visited a given place by summing over the duration of all the stops at that place.

**Move**
The travel between two Stops, which the user will pass though a path of GPS points. The distance of a Move can be computed as the sum of using the haversine distance of this path. Given the distance travelled as well as departure and arrival timestamp from the Stops, the average speed at which the user traveled can be derived. 

### Derived Features
**Home Stay**
The portion (percentage) of the total time elapsed since midnight which was spent at home. Elapsed time is calculated from the departure time of the last known stop.

**Location Variance**
The statistical variance in the latitude- and longitudinal coordinates.

**Number of Places**
The number of places visited today.

**Entropy**
The entropy with respect to time spent at places.

**Normalized Entropy**
The normalized entropy with respect to time spent at places.

**Distance Travelled**
The total distance travelled today (in meters), i.e. not limited to walking or running.

**Routine Index**
The percentage of today that overlapped with the previous, maximally, 28 days.