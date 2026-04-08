// import 'package:logger/logger.dart';

// class AppLogger {
//   // Use SimplePrinter to avoid the "boxy" default look
//   static final Logger _logger = Logger(printer: SimplePrinter(printTime: false));

//   static void d(String message) => _logger.d(message);
//   static void i(String message) => _logger.i(message);
//   static void w(String message) => _logger.w(message);
//   static void e(String message) => _logger.e(message);
// }

// mixin Loggable {
//   // This automatically captures the name of the class using the mixin
//   String get _logTag => '[$runtimeType]';

//   void logD(String message) => AppLogger.d('$_logTag $message');
//   void logI(String message) => AppLogger.i('$_logTag $message');
//   void logW(String message) => AppLogger.w('$_logTag $message');
//   void logE(String message) => AppLogger.e('$_logTag $message');
// }

// extension LogExtensions<T> on T {
//   /// Synchronous: Logs and returns [this].
//   /// Supports: .log("msg") OR .log((val) => "Result: $val")
//   T log(dynamic message, [String? tag]) {
//     final prefix = (tag != null && tag.isNotEmpty) ? '[$tag] ' : '';
//     final logMsg = message is String Function(T) ? message(this) : message.toString();
//     AppLogger.i('$prefix ~ $logMsg');
//     return this;
//   }
// }

// extension FutureLogExtensions<T> on Future<T> {
//   /// Asynchronous: Awaits, logs, and returns the result.
//   /// Supports: .thenLog("msg") OR .thenLog((val) => "Result: $val")
//   Future<T> thenLog(dynamic message, [String? tag]) async {
//     final result = await this;
//     final prefix = (tag != null && tag.isNotEmpty) ? '[$tag] ' : '';
//     final logMsg = message is String Function(T) ? message(result) : message.toString();
//     AppLogger.i('$prefix ~ $logMsg');
//     return result;
//   }
// }
