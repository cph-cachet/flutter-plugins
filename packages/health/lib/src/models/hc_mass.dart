part of health;

class Mass {
  final double value;
  final Type type;

  Mass(this.value, {this.type = Type.GRAMS});

  Mass get grams => Mass(_convertTo(Type.GRAMS), type: Type.GRAMS);
  Mass get kilograms => Mass(_convertTo(Type.KILOGRAMS), type: Type.KILOGRAMS);
  Mass get milligrams =>
      Mass(_convertTo(Type.MILLIGRAMS), type: Type.MILLIGRAMS);
  Mass get micrograms =>
      Mass(_convertTo(Type.MICROGRAMS), type: Type.MICROGRAMS);
  Mass get ounces => Mass(_convertTo(Type.OUNCES), type: Type.OUNCES);
  Mass get pounds => Mass(_convertTo(Type.POUNDS), type: Type.POUNDS);

  Mass as(Type type) => Mass(_convertTo(type), type: type);

  double _convertTo(Type other) => // convert to grams then to the desired unit
      value * type.conversionFactor / other.conversionFactor;

  /// Adds two masses. Always results in grams.
  @override
  Mass operator +(Mass other) {
    final _thisGrams = this.grams;
    final _otherGrams = other.grams;
    final bool typesMatch = _thisGrams.type == _otherGrams.type;
    final Mass sum =
        Mass(_thisGrams.value + _otherGrams.value, type: Type.GRAMS);
    return typesMatch ? sum.as(this.type) : sum;
  }
}
// create a tree structure of mass units and their converison factors with grams as the base unit
// the tree can be used to convert between any two units

enum Type {
  GRAMS(1.0),
  KILOGRAMS(1000.0),
  MILLIGRAMS(1e-3),
  MICROGRAMS(1e-6),
  OUNCES(28.34952),
  POUNDS(453.59237);

  const Type(this.conversionFactor);
  final double conversionFactor; // number of grams in 1 unit of the type
}
