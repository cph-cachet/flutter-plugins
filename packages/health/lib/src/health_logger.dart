part of health;

abstract class HealthLogger {
  void i(String message);

  void d(String message);

  void e(String message, [Exception? exception]);
}
