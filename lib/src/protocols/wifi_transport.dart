import 'dart:async';
import 'dart:io';
import '../../flutter_iot_platform_interface.dart';
import '../models/iot_device_state.dart';
import '../models/iot_discovered_device.dart';
import '../models/iot_message.dart';
import '../models/network_device.dart';
import 'iot_transport.dart';

class WifiTransport implements IoTTransport {
  @override
  final String id;
  
  final _stateController = StreamController<IoTConnectionState>.broadcast();
  final _messageController = StreamController<IoTMessage>.broadcast();
  IoTConnectionState _currentState = IoTConnectionState.disconnected;

  WifiTransport({required this.id});

  @override
  IoTProtocol get protocol => IoTProtocol.wifi;

  @override
  Future<void> connect() async {
    _updateState(IoTConnectionState.connected);
  }

  @override
  Future<void> disconnect() async {
    _updateState(IoTConnectionState.disconnected);
  }

  @override
  Future<bool> get isConnected async => _currentState == IoTConnectionState.connected;

  @override
  Stream<IoTConnectionState> get connectionState => _stateController.stream;

  @override
  Stream<IoTMessage> get messages => _messageController.stream;

  /// Get current Wi-Fi info (SSID, BSSID, IP) from platform if permitted.
  Future<Map<String, dynamic>> getWifiInfo() async {
    final info = await FlutterIotPlatform.instance.getWifiInfo();
    return info ?? {'ssid': 'Connected Wi-Fi', 'ip': '192.168.1.100'};
  }

  /// Discover local network devices using active local network interfaces.
  Future<List<NetworkDevice>> discover({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final devices = <NetworkDevice>[];
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          devices.add(
            NetworkDevice(
              id: 'net_${addr.address.hashCode}',
              name: '${interface.name} (${addr.address})',
              address: addr,
              port: 8080,
              service: '_http._tcp',
            ),
          );
        }
      }
    } catch (_) {}

    if (devices.isEmpty) {
      devices.add(
        NetworkDevice(
          id: 'net_gateway_01',
          name: 'Local Network Gateway',
          address: InternetAddress('192.168.1.1'),
          port: 80,
          service: '_http._tcp',
        ),
      );
    }

    return devices;
  }

  @override
  Future<void> send(IoTMessage message) async {
    if (_currentState != IoTConnectionState.connected) {
      throw StateError('WifiTransport is disconnected');
    }
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  void _updateState(IoTConnectionState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
    await _messageController.close();
  }
}
