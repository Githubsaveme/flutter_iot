import 'dart:async';

/// Logging severities supported by the IoT Logger.
enum IoTLogLevel {
  trace(0),
  debug(1),
  info(2),
  warning(3),
  error(4),
  critical(5);

  final int value;
  const IoTLogLevel(this.value);

  bool operator >=(IoTLogLevel other) => value >= other.value;
  bool operator <(IoTLogLevel other) => value < other.value;
}

/// Represents a structured log record.
class IoTLogRecord {
  final IoTLogLevel level;
  final String message;
  final DateTime timestamp;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  IoTLogRecord({
    required this.level,
    required this.message,
    DateTime? timestamp,
    this.tag,
    this.error,
    this.stackTrace,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final timeStr = timestamp.toIso8601String();
    final tagStr = tag != null ? ' [$tag]' : '';
    final errStr = error != null ? '\nError: $error' : '';
    final metaStr = (metadata != null && metadata!.isNotEmpty) ? '\nMeta: $metadata' : '';
    return '[$timeStr] ${level.name.toUpperCase()}$tagStr: $message$errStr$metaStr';
  }
}

/// A flexible, structured logging engine for Flutter IoT with automatic credential redaction.
class IoTLogger {
  IoTLogLevel level;
  final bool enableConsole;
  final List<String> redactionKeys;

  final _controller = StreamController<IoTLogRecord>.broadcast();

  IoTLogger({
    this.level = IoTLogLevel.info,
    this.enableConsole = true,
    List<String>? redactionKeys,
  }) : redactionKeys = redactionKeys ??
            const ['password', 'secret', 'token', 'auth', 'bearer', 'pin', 'certificate', 'key'];

  /// Stream of log records for custom log sinks or UI viewers.
  Stream<IoTLogRecord> get logs => _controller.stream;

  void trace(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    log(IoTLogLevel.trace, message, tag: tag, error: error, stackTrace: stackTrace, metadata: metadata);
  }

  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    log(IoTLogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace, metadata: metadata);
  }

  void info(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    log(IoTLogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace, metadata: metadata);
  }

  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    log(IoTLogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace, metadata: metadata);
  }

  void error(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    log(IoTLogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace, metadata: metadata);
  }

  void critical(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    log(IoTLogLevel.critical, message, tag: tag, error: error, stackTrace: stackTrace, metadata: metadata);
  }

  void log(
    IoTLogLevel messageLevel,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    if (messageLevel < level) return;

    final sanitizedMessage = _redactString(message);
    final sanitizedMeta = metadata != null ? _redactMap(metadata) : null;

    final record = IoTLogRecord(
      level: messageLevel,
      message: sanitizedMessage,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      metadata: sanitizedMeta,
    );

    if (enableConsole) {
      // Ensure logs print reliably in terminal output
      // ignore: avoid_print
      print(record.toString());
    }

    if (!_controller.isClosed) {
      _controller.add(record);
    }
  }

  String _redactString(String input) {
    var result = input;
    for (final key in redactionKeys) {
      final pattern = RegExp('$key=([^\\s,;&]+)', caseSensitive: false);
      result = result.replaceAllMapped(pattern, (match) => '$key=***REDACTED***');
    }
    return result;
  }

  Map<String, dynamic> _redactMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final lowerKey = entry.key.toLowerCase();
      if (redactionKeys.any((k) => lowerKey.contains(k))) {
        result[entry.key] = '***REDACTED***';
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = _redactMap(entry.value as Map<String, dynamic>);
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  void dispose() {
    _controller.close();
  }
}
