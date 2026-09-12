import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../exceptions/iot_exceptions.dart';
import '../models/iot_device_state.dart';
import '../models/iot_discovered_device.dart';
import '../models/iot_message.dart';
import 'iot_transport.dart';

class TcpTransport implements IoTTransport {
  @override
  final String id;
  final String host;
  final int port;

  Socket? _socket;
  StreamSubscription? _subscription;
  final _stateController = StreamController<IoTConnectionState>.broadcast();
  final _messageController = StreamController<IoTMessage>.broadcast();
  IoTConnectionState _currentState = IoTConnectionState.disconnected;

  TcpTransport({
    required this.id,
    required this.host,
    required this.port,
  });

  @override
  IoTProtocol get protocol => IoTProtocol.tcp;

  @override
  Future<void> connect() async {
    if (_currentState == IoTConnectionState.connected || _currentState == IoTConnectionState.connecting) return;

    _updateState(IoTConnectionState.connecting);
    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 10));

      _subscription = _socket!.listen(
        (Uint8List data) {
          final message = IoTMessage(
            id: 'tcp_${DateTime.now().millisecondsSinceEpoch}',
            topic: '$host:$port',
            payload: data,
            format: IoTMessageFormat.bytes,
            protocol: IoTProtocol.tcp,
          );
          if (!_messageController.isClosed) {
            _messageController.add(message);
          }
        },
        onError: (e) {
          _updateState(IoTConnectionState.error);
        },
        onDone: () {
          _updateState(IoTConnectionState.disconnected);
        },
      );

      _updateState(IoTConnectionState.connected);
    } catch (e) {
      _updateState(IoTConnectionState.error);
      throw IoTConnectionException('Failed to establish TCP socket to $host:$port', cause: e);
    }
  }

  @override
  Future<void> disconnect() async {
    _updateState(IoTConnectionState.disconnecting);
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _socket = null;
    _updateState(IoTConnectionState.disconnected);
  }

  @override
  Future<bool> get isConnected async => _currentState == IoTConnectionState.connected;

  @override
  Stream<IoTConnectionState> get connectionState => _stateController.stream;

  @override
  Stream<IoTMessage> get messages => _messageController.stream;

  @override
  Future<void> send(IoTMessage message) async {
    if (_currentState != IoTConnectionState.connected || _socket == null) {
      throw const IoTConnectionException('TCP socket is not connected');
    }

    try {
      if (message.payload is List<int>) {
        _socket!.add(message.payload as List<int>);
      } else {
        _socket!.write(message.payload.toString());
      }
      await _socket!.flush();
    } catch (e) {
      throw IoTNetworkException('Failed to write data to TCP socket', cause: e);
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
