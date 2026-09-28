import 'package:flutter/foundation.dart';

class RealtimeLogger {
  RealtimeLogger._();

  static const String tag = 'ChatRealtime';

  static void d(String message) => _log('D', message);

  static void i(String message) => _log('I', message);

  static void w(String message) => _log('W', message);

  static void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('E', message);
    if (error != null) {
      debugPrint('[$tag][E] error=$error');
    }
    if (stackTrace != null) {
      debugPrint('[$tag][E] $stackTrace');
    }
  }

  static void _log(String level, String message) {
    debugPrint('[$tag][$level] $message');
  }
}
