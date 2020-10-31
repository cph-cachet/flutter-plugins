part of mobility_app;

class StopsPage extends StatelessWidget {
  final List<Stop> stops;

  StopsPage(this.stops);

  Widget stopEntry(Stop s) {
    String lat = s.geoLocation.latitude.toStringAsFixed(4);
    String lon = s.geoLocation.longitude.toStringAsFixed(4);
    return Container(
        padding: const EdgeInsets.all(2),
        margin: EdgeInsets.all(3),
        child: ListTile(
          leading: Text('Place ${s.placeId}'),
          title: Text('${interval(s.arrival, s.departure)}'),
          trailing: Text('$lat, $lon'),
        ));
  }

  Widget list() {
    return ListView.builder(
        itemCount: stops.length,
        itemBuilder: (ctx, index) => stopEntry(stops[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: list(),
    );
  }
}
