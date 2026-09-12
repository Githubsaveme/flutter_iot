import 'dart:async';
import '../../flutter_iot_platform_interface.dart';
import '../adapters/iot_device_adapter.dart';
import '../capabilities/iot_capabilities.dart';
import '../discovery/iot_discovery_manager.dart';
import '../events/iot_event_bus.dart';
import '../logging/iot_logger.dart';
import '../models/iot_discovered_device.dart';
import '../monitoring/iot_background_monitoring_manager.dart';
import '../pairing/iot_pairing_manager.dart';
import '../permissions/iot_permissions.dart';
import '../protocols/ble_transport.dart';
import '../protocols/http_transport.dart';
import '../protocols/mqtt_transport.dart';
import '../protocols/tcp_transport.dart';
import '../protocols/udp_transport.dart';
import '../protocols/websocket_transport.dart';
import '../protocols/wifi_transport.dart';
import '../registry/iot_device_registry.dart';
import 'iot_config.dart';

class IoTManager {
  static final IoTManager instance = IoTManager._internal();

  IoTConfig _config = const IoTConfig();
  late IoTLogger logger;
  late IoTCapabilities capabilities;
  final permissions = IoTPermissionsManager();
  final discovery = IoTDiscoveryManager();
  final pairing = IoTPairingManager();
  final events = IoTEventBus();
  final registry = IoTDeviceRegistry();
  final monitoring = IoTBackgroundMonitoringManager();

  final List<IoTDeviceAdapter> _adapters = [];
  bool _initialized = false;

  IoTManager._internal() {
    logger = IoTLogger(level: _config.logLevel, enableConsole: _config.enableLogging);
    capabilities = IoTCapabilities.forPlatform('unknown');
  }

  bool get isInitialized => _initialized;
  IoTConfig get config => _config;

  /// Initialize the Flutter IoT manager with runtime configuration and capability detection.
  Future<void> initialize([IoTConfig? config]) async {
    if (config != null) {
      _config = config;
      logger.level = _config.logLevel;
    }

    try {
      final platformStr = await FlutterIotPlatform.instance.getPlatformVersion() ?? 'unknown';
      capabilities = IoTCapabilities.forPlatform(platformStr);
      _initialized = true;
      logger.info('Flutter IoT Manager initialized successfully on $platformStr', tag: 'IoTManager');
    } catch (e, st) {
      logger.error('Failed to initialize Flutter IoT Manager', tag: 'IoTManager', error: e, stackTrace: st);
      capabilities = IoTCapabilities.forPlatform('fallback');
      _initialized = true;
    }
  }

  /// Register custom device adapter.
  void registerAdapter(IoTDeviceAdapter adapter) {
    _adapters.add(adapter);
    logger.info('Registered device adapter: ${adapter.adapterId}', tag: 'IoTManager');
  }

  /// Create or obtain a BLE transport instance.
  BleTransport ble({required String deviceId}) {
    return BleTransport(id: 'ble_$deviceId', targetDeviceId: deviceId);
  }

  /// Create or obtain an MQTT transport instance.
  MqttTransport mqtt(MqttConfig config) {
    return MqttTransport(id: 'mqtt_${config.clientId}', config: config);
  }

  /// Create or obtain a WebSocket transport instance.
  WebSocketTransport webSocket(String url) {
    return WebSocketTransport(id: 'ws_${url.hashCode}', url: url);
  }

  /// Create or obtain an HTTP transport instance.
  HttpTransport http(String baseUrl) {
    return HttpTransport(id: 'http_${baseUrl.hashCode}', baseUrl: baseUrl);
  }

  /// Create or obtain a TCP transport instance.
  TcpTransport tcp({required String host, required int port}) {
    return TcpTransport(id: 'tcp_${host}_$port', host: host, port: port);
  }

  /// Create or obtain a UDP transport instance.
  UdpTransport udp({int bindPort = 0}) {
    return UdpTransport(id: 'udp_$bindPort', bindPort: bindPort);
  }

  /// Obtain Wi-Fi transport.
  WifiTransport get wifi => WifiTransport(id: 'wifi_default');

  /// Shortcut helper to scan for devices.
  Stream<IoTDiscoveredDevice> scan({List<IoTProtocol>? protocols, Duration timeout = const Duration(seconds: 10)}) {
    return discovery.scan(protocols: protocols, timeout: timeout);
  }

  /// Dispose manager resources.
  Future<void> dispose() async {
    logger.dispose();
    discovery.dispose();
    events.dispose();
    registry.dispose();
    _initialized = false;
  }
}
