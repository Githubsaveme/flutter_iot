import '../logging/iot_logger.dart';
import 'power_policy.dart';
import 'reconnect_policy.dart';

class IoTConfig {
  final bool enableLogging;
  final IoTLogLevel logLevel;
  final bool autoReconnect;
  final ReconnectPolicy reconnectPolicy;
  final IoTPowerPolicy powerPolicy;
  final int offlineQueueLimit;

  const IoTConfig({
    this.enableLogging = true,
    this.logLevel = IoTLogLevel.info,
    this.autoReconnect = true,
    this.reconnectPolicy = const ReconnectPolicy(),
    this.powerPolicy = const IoTPowerPolicy(),
    this.offlineQueueLimit = 100,
  });
}
