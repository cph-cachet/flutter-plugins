part of health;

abstract class HeathLogger {
  void i(String message);

  void d(String message);

  void e(String message, [Exception? exception]);
}
