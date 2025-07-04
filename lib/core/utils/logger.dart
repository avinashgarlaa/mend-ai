// ignore_for_file: avoid_print

class Logger {
  static void log(String message) {
    // You can extend this with different log levels or external logging services
    // For now, just print with a timestamp
    final time = DateTime.now().toIso8601String();
    print('[$time] $message');
  }
}
