import 'package:logger/logger.dart' as log;

class Logger {
  final _logger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  void debug(dynamic message) => _logger.d(message);
  void info(dynamic message) => _logger.i(message);
  void warning(dynamic message) => _logger.w(message);
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) => 
      _logger.e(message, error: error, stackTrace: stackTrace);
}
