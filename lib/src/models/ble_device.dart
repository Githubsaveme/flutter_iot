import 'dart:async';
import 'iot_command.dart';
import 'iot_device.dart';
import 'iot_device_state.dart';
import 'iot_discovered_device.dart';
import 'standard_device_types.dart';

enum BleConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

class BleDevice implements IoTDevice {
  @override
  final String id;
  @override
  final String? name;
  final int? rssi;
  final Map<int, List<int>> manufacturerData;
  final Map<String, List<int>> serviceData;
  final List<String> serviceUuids;
  final BleConnectionState connectionStatus;
  final bool isConnectable;
  final int? txPowerLevel;

  final StreamController<IoTDeviceState> _stateController = StreamController<IoTDeviceState>.broadcast();

  BleDevice({
    required this.id,
    this.name,
    this.rssi,
    this.manufacturerData = const {},
    this.serviceData = const {},
    this.serviceUuids = const [],
    BleConnectionState state = BleConnectionState.disconnected,
    this.isConnectable = true,
    this.txPowerLevel,
  }) : connectionStatus = state;

  @override
  IoTProtocol get protocol => IoTProtocol.ble;

  @override
  String get type => StandardDeviceTypes.custom;

  @override
  IoTDeviceState get state => IoTDeviceState(
        online: connectionStatus == BleConnectionState.connected,
        connectionState: _mapState(connectionStatus),
      );

  @override
  Stream<IoTDeviceState> get stateStream => _stateController.stream;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<dynamic> execute(IoTCommand command) async {
    return true;
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
  }

  IoTConnectionState _mapState(BleConnectionState status) {
    switch (status) {
      case BleConnectionState.connected:
        return IoTConnectionState.connected;
      case BleConnectionState.connecting:
        return IoTConnectionState.connecting;
      case BleConnectionState.disconnecting:
        return IoTConnectionState.disconnecting;
      case BleConnectionState.disconnected:
        return IoTConnectionState.disconnected;
    }
  }

  BleDevice copyWith({
    String? id,
    String? name,
    int? rssi,
    Map<int, List<int>>? manufacturerData,
    Map<String, List<int>>? serviceData,
    List<String>? serviceUuids,
    BleConnectionState? state,
    bool? isConnectable,
    int? txPowerLevel,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      manufacturerData: manufacturerData ?? this.manufacturerData,
      serviceData: serviceData ?? this.serviceData,
      serviceUuids: serviceUuids ?? this.serviceUuids,
      state: state ?? connectionStatus,
      isConnectable: isConnectable ?? this.isConnectable,
      txPowerLevel: txPowerLevel ?? this.txPowerLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rssi': rssi,
        'manufacturerData': manufacturerData.map((k, v) => MapEntry(k.toString(), v)),
        'serviceData': serviceData,
        'serviceUuids': serviceUuids,
        'state': connectionStatus.name,
        'isConnectable': isConnectable,
        'txPowerLevel': txPowerLevel,
      };

  @override
  String toString() => 'BleDevice(id: $id, name: ${name ?? "Unknown"}, rssi: $rssi, state: ${connectionStatus.name})';
}
