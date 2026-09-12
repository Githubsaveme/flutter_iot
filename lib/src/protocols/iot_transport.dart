import 'dart:async';
import '../models/iot_device_state.dart';
import '../models/iot_discovered_device.dart';
import '../models/iot_message.dart';

abstract class IoTTransport {
  /// Unique identifier of this transport instance.
  String get id;

  /// Protocol type of this transport.
  IoTProtocol get protocol;

  /// Establish connection to target endpoint.
  Future<void> connect();

  /// Disconnect transport.
  Future<void> disconnect();

  /// Check whether connection is active.
  Future<bool> get isConnected;

  /// Stream of connection state changes.
  Stream<IoTConnectionState> get connectionState;

  /// Send an IoT message through this transport.
  Future<void> send(IoTMessage message);

  /// Stream of incoming messages received on this transport.
  Stream<IoTMessage> get messages;

  /// Clean up resources associated with this transport.
  Future<void> dispose();
}
