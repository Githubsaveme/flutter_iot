import 'dart:async';
import 'iot_command.dart';
import 'iot_device_state.dart';
import 'iot_discovered_device.dart';

/// Unified device contract across all supported protocols and platforms.
abstract class IoTDevice {
  /// Unique identifier of the device.
  String get id;

  /// Display name of the device if available.
  String? get name;

  /// Communication protocol utilized by this device.
  IoTProtocol get protocol;

  /// Device classification type (e.g. smart_light, temperature_sensor).
  String get type;

  /// Current state of the device.
  IoTDeviceState get state;

  /// Stream of real-time device state updates.
  Stream<IoTDeviceState> get stateStream;

  /// Establish connection to device.
  Future<void> connect();

  /// Disconnect device connection.
  Future<void> disconnect();

  /// Execute an [IoTCommand] on this device.
  Future<dynamic> execute(IoTCommand command);

  /// Clean up and release device resources.
  Future<void> dispose();
}
