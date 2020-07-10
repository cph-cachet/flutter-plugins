part of mobility_test;

void printList(List l) {
  for (int i = 0; i < l.length; i++) {
    print('[$i] ${l[i]}');
  }

  print('-' * 50);
}

double abs(double x) => x >= 0 ? x : -x;

class LocationDTO {
  double lat, lon;

  LocationDTO(this.lat, this.lon);

}