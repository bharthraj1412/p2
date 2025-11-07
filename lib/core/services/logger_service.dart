import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
    level: Level.debug,
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void verbose(String message) {
    _logger.v(message);
  }

  // Log payment events
  static void logPaymentEvent(String event, Map<String, dynamic> data) {
    info('Payment: $event', data.toString());
  }

  // Log commission events
  static void logCommissionEvent(String event, Map<String, dynamic> data) {
    info('Commission: $event', data.toString());
  }

  // Log auth events
  static void logAuthEvent(String event, Map<String, dynamic> data) {
    info('Auth: $event', data.toString());
  }
}
