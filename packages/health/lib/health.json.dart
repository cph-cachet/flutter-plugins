part of 'health.dart';

bool _fromJsonFunctionsRegistered = false;

/// Register all the fromJson functions for the health domain classes.
void _registerFromJsonFunctions() {
  if (_fromJsonFunctionsRegistered) return;

  // Protocol classes
  FromJsonFactory().registerAll([
    HealthValue(),
    NumericHealthValue(numericValue: 12),
    AudiogramHealthValue(
      frequencies: [],
      leftEarSensitivities: [],
      rightEarSensitivities: [],
    ),
    ElectrocardiogramHealthValue(voltageValues: []),
    ElectrocardiogramVoltageValue(voltage: 12, timeSinceSampleStart: 0),
    NutritionHealthValue(),
  ]);

  _fromJsonFunctionsRegistered = true;
}
