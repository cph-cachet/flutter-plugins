part of mobility_app;

class MovesPage extends StatelessWidget {
  final List<Move> moves;

  MovesPage(this.moves);

  Widget moveEntry(Move m) {
    return Container(
        padding: const EdgeInsets.all(2),
        margin: EdgeInsets.all(3),
        child: ListTile(
          leading: Text('Place ${m.stopFrom.placeId} → ${m.stopTo.placeId}'),
          title: Text('${m.distance.toInt()} meters'),
          trailing: Text('${formatDuration(m.duration)}'),
        ));
  }




  Widget list() {
    return ListView.builder(
        itemCount: moves.length,
        itemBuilder: (ctx, index) => moveEntry(moves[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: list(),
    );
  }
}
