/// Hierarchy of typed exceptions thrown by the Flutter IoT plugin.
/// 
/// Public APIs avoid throwing generic [Exception] instances, ensuring callers
/// can handle errors with pattern matching and typed catches.
sealed class IoTException implements Exception {
  /// A human-readable description of the error.
  final String message;

  /// A short machine-readable error code.
  final String code;

  /// Optional contextual details.
  final Map<String, dynamic>? details;

  /// Optional underlying error or stack trace reference.
  final dynamic cause;

  const IoTException(
    this.message, {
    required this.code,
    this.details,
    this.cause,
  });

  @override
  String toString() => '$runtimeType [$code]: $message';
}

/// Thrown when a transport fails to establish or maintain a connection.
class IoTConnectionException extends IoTException {
  const IoTConnectionException(
    super.message, {
    super.code = 'CONNECTION_FAILED',
    super.details,
    super.cause,
  });
}

/// Thrown when an operation exceeds its configured duration limit.
class IoTTimeoutException extends IoTException {
  final Duration timeout;

  const IoTTimeoutException(
    super.message, {
    required this.timeout,
    super.code = 'TIMEOUT',
    super.details,
    super.cause,
  });
}

/// Thrown when credentials, tokens, or authentication handshakes fail.
class IoTAuthenticationException extends IoTException {
  const IoTAuthenticationException(
    super.message, {
    super.code = 'AUTH_FAILED',
    super.details,
    super.cause,
  });
}

/// Thrown when required system permissions (Bluetooth, Location, Nearby) are missing.
class IoTPermissionException extends IoTException {
  final String permission;

  const IoTPermissionException(
    super.message, {
    required this.permission,
    super.code = 'PERMISSION_DENIED',
    super.details,
    super.cause,
  });
}

/// Thrown when device discovery operations fail or encounter errors.
class IoTDiscoveryException extends IoTException {
  const IoTDiscoveryException(
    super.message, {
    super.code = 'DISCOVERY_FAILED',
    super.details,
    super.cause,
  });
}

/// Thrown when a protocol violation, invalid frame, or unexpected transport state occurs.
class IoTProtocolException extends IoTException {
  const IoTProtocolException(
    super.message, {
    super.code = 'PROTOCOL_ERROR',
    super.details,
    super.cause,
  });
}

/// Thrown when attempting to use a feature unsupported on the current platform or device.
class IoTUnsupportedException extends IoTException {
  final String feature;

  const IoTUnsupportedException(
    super.message, {
    required this.feature,
    super.code = 'UNSUPPORTED_FEATURE',
    super.details,
    super.cause,
  });
}

/// Thrown when a targeted device cannot be located in the registry or local network.
class IoTDeviceNotFoundException extends IoTException {
  final String deviceId;

  const IoTDeviceNotFoundException(
    super.message, {
    required this.deviceId,
    super.code = 'DEVICE_NOT_FOUND',
    super.details,
    super.cause,
  });
}

/// Thrown when a device cannot process a request because it is executing another operation.
class IoTDeviceBusyException extends IoTException {
  final String deviceId;

  const IoTDeviceBusyException(
    super.message, {
    required this.deviceId,
    super.code = 'DEVICE_BUSY',
    super.details,
    super.cause,
  });
}

/// Thrown when general network connectivity loss occurs.
class IoTNetworkException extends IoTException {
  const IoTNetworkException(
    super.message, {
    super.code = 'NETWORK_ERROR',
    super.details,
    super.cause,
  });
}

/// Thrown when encoding or decoding message payloads fails.
class IoTSerializationException extends IoTException {
  const IoTSerializationException(
    super.message, {
    super.code = 'SERIALIZATION_ERROR',
    super.details,
    super.cause,
  });
}

/// Thrown when device pairing or provisioning process fails.
class IoTPairingException extends IoTException {
  const IoTPairingException(
    super.message, {
    super.code = 'PAIRING_FAILED',
    super.details,
    super.cause,
  });
}
