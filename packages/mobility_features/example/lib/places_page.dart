part of mobility_app;

class PlacesPage extends StatelessWidget {
  final List<Place> places;

  PlacesPage(this.places);

  Widget placeEntry(Place p) {
    String lat = p.geoLocation.latitude.toStringAsFixed(4);
    String lon = p.geoLocation.longitude.toStringAsFixed(4);

    return Container(
        padding: const EdgeInsets.all(2),
        margin: EdgeInsets.all(3),
        child: ListTile(
          leading: Text('Place ID ${p.id}'),
          title: Text('$lat, $lon'),
          trailing: Text('${formatDuration(p.duration)}'),
        ));
  }

  Widget list() {
    return ListView.builder(
        itemCount: places.length,
        itemBuilder: (ctx, index) => placeEntry(places[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: list(),
    );
  }
}
