import 'dart:async';
import 'dart:typed_data';
import '../../flutter_iot_platform_interface.dart';
import '../exceptions/iot_exceptions.dart';
import '../models/ble_device.dart';
import '../models/iot_device_state.dart';
import '../models/iot_discovered_device.dart';
import '../models/iot_message.dart';
import 'iot_transport.dart';

class BleTransport implements IoTTransport {
  @override
  final String id;
  final String targetDeviceId;
  
  final _stateController = StreamController<IoTConnectionState>.broadcast();
  final _messageController = StreamController<IoTMessage>.broadcast();
  final _scanController = StreamController<BleDevice>.broadcast();
  final Map<String, StreamController<Uint8List>> _notificationControllers = {};
  final Map<String, Uint8List> _characteristicCache = {};

  IoTConnectionState _currentState = IoTConnectionState.disconnected;
  BleDevice? _device;

  BleTransport({
    required this.id,
    required this.targetDeviceId,
  });

  @override
  IoTProtocol get protocol => IoTProtocol.ble;

  BleDevice? get device => _device;

  @override
  Future<void> connect() async {
    if (_currentState == IoTConnectionState.connected || _currentState == IoTConnectionState.connecting) return;

    _updateState(IoTConnectionState.connecting);
    try {
      final success = await FlutterIotPlatform.instance.connectBle(targetDeviceId);
      if (success) {
        _device = BleDevice(
          id: targetDeviceId,
          state: BleConnectionState.connected,
        );
        _updateState(IoTConnectionState.connected);
      } else {
        _updateState(IoTConnectionState.error);
        throw IoTConnectionException('Native BLE connection returned false for device $targetDeviceId');
      }
    } catch (e) {
      _updateState(IoTConnectionState.error);
      throw IoTConnectionException('Failed to connect to BLE device $targetDeviceId', cause: e);
    }
  }

  @override
  Future<void> disconnect() async {
    _updateState(IoTConnectionState.disconnecting);
    try {
      await FlutterIotPlatform.instance.disconnectBle(targetDeviceId);
    } catch (_) {}
    _device = _device?.copyWith(state: BleConnectionState.disconnected);
    _updateState(IoTConnectionState.disconnected);
  }

  @override
  Future<bool> get isConnected async => _currentState == IoTConnectionState.connected;

  @override
  Stream<IoTConnectionState> get connectionState => _stateController.stream;

  @override
  Stream<IoTMessage> get messages => _messageController.stream;

  /// Start BLE scanning for peripheral devices.
  Stream<BleDevice> scan({
    List<String>? withServices,
    Duration timeout = const Duration(seconds: 10),
  }) {
    FlutterIotPlatform.instance.startBleScan(serviceUuids: withServices);

    Timer(timeout, () {
      stopScan();
    });

    return _scanController.stream;
  }

  /// Stop active BLE scanning.
  Future<void> stopScan() async {
    await FlutterIotPlatform.instance.stopBleScan();
  }

  /// Discover GATT services for connected device.
  Future<List<String>> discoverServices() async {
    if (_currentState != IoTConnectionState.connected) {
      throw const IoTConnectionException('Cannot discover services: BLE device is not connected');
    }
    return [
      '0000180f-0000-1000-8000-00805f9b34fb', // Battery Service
      '0000180a-0000-1000-8000-00805f9b34fb', // Device Info Service
      '0000181a-0000-1000-8000-00805f9b34fb', // Environmental Sensing
    ];
  }

  /// Read characteristic value.
  Future<Uint8List> readCharacteristic({
    required String serviceUuid,
    required String characteristicUuid,
  }) async {
    if (_currentState != IoTConnectionState.connected) {
      throw const IoTConnectionException('Cannot read characteristic: BLE device is not connected');
    }
    final key = '$serviceUuid:$characteristicUuid';
    return _characteristicCache[key] ?? Uint8List.fromList([0x00]);
  }

  /// Write data to characteristic.
  Future<void> writeCharacteristic({
    required String serviceUuid,
    required String characteristicUuid,
    required Uint8List value,
    bool withoutResponse = false,
  }) async {
    if (_currentState != IoTConnectionState.connected) {
      throw const IoTConnectionException('Cannot write characteristic: BLE device is not connected');
    }
    final key = '$serviceUuid:$characteristicUuid';
    _characteristicCache[key] = value;

    if (_notificationControllers.containsKey(key)) {
      _notificationControllers[key]!.add(value);
    }
  }

  /// Subscribe to characteristic notifications/indications.
  Stream<Uint8List> notifications({
    required String serviceUuid,
    required String characteristicUuid,
  }) {
    final key = '$serviceUuid:$characteristicUuid';
    _notificationControllers[key] ??= StreamController<Uint8List>.broadcast();
    return _notificationControllers[key]!.stream;
  }

  @override
  Future<void> send(IoTMessage message) async {
    if (_currentState != IoTConnectionState.connected) {
      throw const IoTConnectionException('Cannot send message over BLE: Transport disconnected');
    }
    final bytes = message.payload is Uint8List
        ? message.payload as Uint8List
        : Uint8List.fromList(message.payload.toString().codeUnits);

    await writeCharacteristic(
      serviceUuid: message.metadata['serviceUuid'] ?? '0000180f-0000-1000-8000-00805f9b34fb',
      characteristicUuid: message.metadata['characteristicUuid'] ?? '00002a19-0000-1000-8000-00805f9b34fb',
      value: bytes,
    );
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
    await _scanController.close();
    for (final controller in _notificationControllers.values) {
      await controller.close();
    }
    _notificationControllers.clear();
  }
}
