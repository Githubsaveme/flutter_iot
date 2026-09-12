import 'dart:async';

enum IoTEventType {
  deviceDiscovered,
  deviceConnected,
  deviceDisconnected,
  deviceUpdated,
  sensorUpdated,
  commandSent,
  commandCompleted,
  commandFailed,
  connectionLost,
  connectionRestored,
  permissionChanged,
  adapterStateChanged,
  error,
}

class IoTEvent {
  final IoTEventType type;
  final String? deviceId;
  final dynamic payload;
  final DateTime timestamp;

  IoTEvent({
    required this.type,
    this.deviceId,
    this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'IoTEvent(type: ${type.name}, deviceId: $deviceId, timestamp: $timestamp)';
}

class IoTEventBus {
  final _controller = StreamController<IoTEvent>.broadcast();

  Stream<IoTEvent> get events => _controller.stream;

  Stream<IoTEvent> on(IoTEventType type) {
    return _controller.stream.where((e) => e.type == type);
  }

  void emit(IoTEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
