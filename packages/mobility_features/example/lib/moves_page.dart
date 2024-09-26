part of 'main.dart';

class MovesPage extends StatelessWidget {
  final List<Move> moves;

  const MovesPage(this.moves, {super.key});

  Widget moveEntry(Move m) => Container(
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(3),
      child: ListTile(
        leading: Text('Place ${m.stopFrom.placeId} → ${m.stopTo.placeId}'),
        title: Text('${m.distance?.toInt()} meters'),
        trailing: Text(formatDuration(m.duration)),
      ));

  Widget list() => ListView.builder(
      itemCount: moves.length,
      itemBuilder: (ctx, index) => moveEntry(moves[index]));

  @override
  Widget build(BuildContext context) => Container(child: list());
}
