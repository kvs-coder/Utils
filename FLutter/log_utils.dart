class LogUtils {
  static void debug(String className, String method, dynamic message) {
    final isProduction = bool.fromEnvironment('dart.vm.product');
    if (!isProduction) {
      _log('DEBUG', className, method, '$message');
    }
  }

  static void info(String className, String method, dynamic message) =>
      _log('INFO', className, method, '$message');

  static void warning(String className, String method, dynamic message) =>
      _log('WARNING', className, method, '$message');

  static void error(String className, String method, dynamic message) =>
      _log('ERROR', className, method, '$message');

  static void _log(
          String log, String className, String method, String description) =>
      print(
          '$log: ${DateTime.now()} - $className: $method, message: $description');
}
