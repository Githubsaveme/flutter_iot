import 'flutter_iot_platform_interface.dart';
import 'src/core/iot_manager.dart';

export 'flutter_iot_platform_interface.dart';
export 'src/adapters/iot_device_adapter.dart';
export 'src/capabilities/iot_capabilities.dart';
export 'src/capabilities/iot_feature.dart';
export 'src/codecs/iot_codec.dart';
export 'src/core/iot_config.dart';
export 'src/core/iot_manager.dart';
export 'src/core/offline_queue.dart';
export 'src/core/power_policy.dart';
export 'src/core/reconnect_policy.dart';
export 'src/discovery/iot_discovery_manager.dart';
export 'src/events/iot_event_bus.dart';
export 'src/exceptions/iot_exceptions.dart';
export 'src/logging/iot_logger.dart';
export 'src/models/ble_device.dart';
export 'src/models/iot_command.dart';
export 'src/models/iot_device.dart';
export 'src/models/iot_device_profile.dart';
export 'src/models/iot_device_state.dart';
export 'src/models/iot_discovered_device.dart';
export 'src/models/iot_message.dart';
export 'src/models/iot_sensor.dart';
export 'src/models/network_device.dart';
export 'src/models/standard_device_types.dart';
export 'src/models/telemetry_event.dart';
export 'src/monitoring/iot_background_monitoring_manager.dart';
export 'src/pairing/iot_pairing_manager.dart';
export 'src/permissions/iot_permissions.dart';
export 'src/protocols/ble_transport.dart';
export 'src/protocols/http_transport.dart';
export 'src/protocols/iot_transport.dart';
export 'src/protocols/mqtt_transport.dart';
export 'src/protocols/tcp_transport.dart';
export 'src/protocols/udp_transport.dart';
export 'src/protocols/websocket_transport.dart';
export 'src/protocols/wifi_transport.dart';
export 'src/registry/iot_device_registry.dart';

/// Legacy plugin class for backward compatibility.
class FlutterIot {
  Future<String?> getPlatformVersion() {
    return FlutterIotPlatform.instance.getPlatformVersion();
  }
}

/// Central facade accessor for Flutter IoT Plugin.
class FlutterIoT {
  FlutterIoT._();

  /// Singleton access point for [IoTManager].
  static IoTManager get instance => IoTManager.instance;
}
