import '../models/iot_command.dart';
import '../models/iot_device_state.dart';
import '../models/iot_discovered_device.dart';

abstract class IoTDeviceAdapter {
  /// Unique identifier or manufacturer key of this adapter.
  String get adapterId;

  /// Check whether this adapter supports the given discovered device.
  bool supports(IoTDiscoveredDevice device);

  /// Connect to device.
  Future<void> connect();

  /// Disconnect device.
  Future<void> disconnect();

  /// Execute command on device.
  Future<dynamic> execute(IoTCommand command);

  /// Stream of device state updates.
  Stream<IoTDeviceState> get stateStream;
}
