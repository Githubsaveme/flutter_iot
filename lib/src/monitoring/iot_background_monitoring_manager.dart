import '../../flutter_iot_platform_interface.dart';
import '../capabilities/iot_capabilities.dart';
import '../models/iot_discovered_device.dart';

class MonitoringConfig {
  final Duration interval;
  final List<IoTProtocol> protocols;
  final bool foregroundServiceOnAndroid;
  final String? notificationTitle;
  final String? notificationBody;

  const MonitoringConfig({
    this.interval = const Duration(minutes: 15),
    this.protocols = const [IoTProtocol.ble, IoTProtocol.mqtt],
    this.foregroundServiceOnAndroid = true,
    this.notificationTitle = 'IoT Background Monitor',
    this.notificationBody = 'Monitoring connected IoT devices',
  });
}

class IoTBackgroundMonitoringManager {
  bool _isMonitoring = false;

  bool get isMonitoring => _isMonitoring;

  /// Start background device monitoring if supported by the platform.
  Future<bool> start(MonitoringConfig config) async {
    final capabilities = await FlutterIotPlatform.instance.getPlatformVersion();
    final caps = IoTCapabilities.forPlatform(capabilities ?? 'unknown');

    if (!caps.backgroundMonitoring) {
      return false;
    }

    final success = await FlutterIotPlatform.instance.startBackgroundMonitoring(
      intervalMinutes: config.interval.inMinutes,
      notificationTitle: config.notificationTitle,
      notificationBody: config.notificationBody,
    );

    _isMonitoring = success;
    return success;
  }

  /// Stop background device monitoring.
  Future<void> stop() async {
    await FlutterIotPlatform.instance.stopBackgroundMonitoring();
    _isMonitoring = false;
  }
}
