part of health;

class Energy {
  final double value;
  final EType type;

  Energy(this.value, {this.type = EType.CALORIES});
  Energy get calories =>
      Energy(_convertTo(EType.CALORIES), type: EType.CALORIES);
  Energy get kilocalories =>
      Energy(_convertTo(EType.KILOCALORIES), type: EType.KILOCALORIES);
  Energy get joules => Energy(_convertTo(EType.JOULES), type: EType.JOULES);
  Energy get kilojoules =>
      Energy(_convertTo(EType.KILOJOULES), type: EType.KILOJOULES);

  double _convertTo(EType other) =>
      value * type.conversionFactor / other.conversionFactor;
  Energy as(EType type) => Energy(_convertTo(type), type: type);

  /// Adds two masses. Always results in kilocalories.
  @override
  Energy operator +(Energy other) {
    final _thisKcal = this.kilocalories;
    final _otherKcal = other.kilocalories;
    final bool typesMatch = _thisKcal.type == _otherKcal.type;
    final Energy sum =
        Energy(_thisKcal.value + _otherKcal.value, type: EType.KILOCALORIES);
    return typesMatch ? sum.as(this.type) : sum;
  }
}

enum EType {
  CALORIES(1e-3),
  KILOCALORIES(1.0),
  JOULES(2.390057361e-4),
  KILOJOULES(2.390057361e-1);

  const EType(this.conversionFactor);
  final double conversionFactor; // number of kilocalories in 1 unit of the type
}
