part of health;

class Energy {
  final double value;
  final EType type;

  Energy(this.value, {this.type = EType.CALORIES});

  get getInCalories => value;

  get getInKilocalories => getInCalories / 1000.0;

  get getInJoules => getInCalories / 0.2390057361;

  get getInKilojoules => getInCalories / 239.0057361;
}

enum EType { CALORIES, KILOCALORIES, JOULES, KILOJOULES }
