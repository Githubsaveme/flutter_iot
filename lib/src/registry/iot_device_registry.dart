import 'dart:async';
import '../models/iot_discovered_device.dart';

abstract class IoTDeviceStorage {
  Future<void> saveDevice(IoTDiscoveredDevice device);
  Future<void> removeDevice(String deviceId);
  Future<List<IoTDiscoveredDevice>> loadDevices();
}

class InMemoryDeviceStorage implements IoTDeviceStorage {
  final Map<String, IoTDiscoveredDevice> _storage = {};

  @override
  Future<void> saveDevice(IoTDiscoveredDevice device) async {
    _storage[device.id] = device;
  }

  @override
  Future<void> removeDevice(String deviceId) async {
    _storage.remove(deviceId);
  }

  @override
  Future<List<IoTDiscoveredDevice>> loadDevices() async {
    return _storage.values.toList();
  }
}

class IoTDeviceRegistry {
  final IoTDeviceStorage _storage;
  final Map<String, IoTDiscoveredDevice> _devices = {};
  final Set<String> _favorites = {};

  final _controller = StreamController<List<IoTDiscoveredDevice>>.broadcast();

  IoTDeviceRegistry({IoTDeviceStorage? storage}) : _storage = storage ?? InMemoryDeviceStorage();

  Stream<List<IoTDiscoveredDevice>> get devicesStream => _controller.stream;

  List<IoTDiscoveredDevice> get registeredDevices => _devices.values.toList();

  Future<void> register(IoTDiscoveredDevice device) async {
    _devices[device.id] = device;
    await _storage.saveDevice(device);
    _notify();
  }

  Future<void> unregister(String deviceId) async {
    _devices.remove(deviceId);
    _favorites.remove(deviceId);
    await _storage.removeDevice(deviceId);
    _notify();
  }

  IoTDiscoveredDevice? get(String deviceId) => _devices[deviceId];

  void toggleFavorite(String deviceId) {
    if (_favorites.contains(deviceId)) {
      _favorites.remove(deviceId);
    } else {
      _favorites.add(deviceId);
    }
    _notify();
  }

  bool isFavorite(String deviceId) => _favorites.contains(deviceId);

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(registeredDevices);
    }
  }

  void dispose() {
    _controller.close();
  }
}
