part of health;

class Mass {
  final double value;
  final Type type;

  Mass(this.value, {this.type = Type.GRAMS});

  get getInGram => value;

  get getInKilograms => getInGram / 1000.0;

  get getInMilligrams => getInGram / 0.001;

  get getInMicrograms => getInGram / 0.000001;

  get getInOunces => getInGram / 28.34952;

  get getInPounds => getInGram / 453.59237;
}

enum Type {
  GRAMS,
  KILOGRAMS,
  MILLIGRAMS,
  MICROGRAMS,
  OUNCES,
  POUNDS,
}
