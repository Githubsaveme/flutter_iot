import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../exceptions/iot_exceptions.dart';
import '../models/iot_device_state.dart';
import '../models/iot_discovered_device.dart';
import '../models/iot_message.dart';
import 'iot_transport.dart';

class WebSocketTransport implements IoTTransport {
  @override
  final String id;
  final String url;
  final Map<String, dynamic>? headers;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _stateController = StreamController<IoTConnectionState>.broadcast();
  final _messageController = StreamController<IoTMessage>.broadcast();
  IoTConnectionState _currentState = IoTConnectionState.disconnected;

  WebSocketTransport({
    required this.id,
    required this.url,
    this.headers,
  });

  @override
  IoTProtocol get protocol => IoTProtocol.webSocket;

  @override
  Future<void> connect() async {
    if (_currentState == IoTConnectionState.connected || _currentState == IoTConnectionState.connecting) return;

    _updateState(IoTConnectionState.connecting);
    try {
      final uri = Uri.parse(url);
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        (data) {
          _handleIncomingData(data);
        },
        onError: (e) {
          _updateState(IoTConnectionState.error);
          throw IoTConnectionException('WebSocket stream error', cause: e);
        },
        onDone: () {
          _updateState(IoTConnectionState.disconnected);
        },
      );

      _updateState(IoTConnectionState.connected);
    } catch (e) {
      _updateState(IoTConnectionState.error);
      throw IoTConnectionException('Failed to connect to WebSocket at $url', cause: e);
    }
  }

  @override
  Future<void> disconnect() async {
    _updateState(IoTConnectionState.disconnecting);
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
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
    if (_currentState != IoTConnectionState.connected || _channel == null) {
      throw const IoTConnectionException('WebSocket is not connected');
    }

    try {
      final payload = message.payload is String ? message.payload : jsonEncode(message.payload);
      _channel!.sink.add(payload);
    } catch (e) {
      throw IoTNetworkException('Failed to send message over WebSocket', cause: e);
    }
  }

  void _handleIncomingData(dynamic data) {
    dynamic parsedPayload = data;
    var format = IoTMessageFormat.text;

    if (data is String) {
      try {
        parsedPayload = jsonDecode(data);
        format = IoTMessageFormat.json;
      } catch (_) {
        format = IoTMessageFormat.text;
      }
    } else if (data is List<int>) {
      format = IoTMessageFormat.bytes;
    }

    final message = IoTMessage(
      id: 'ws_${DateTime.now().millisecondsSinceEpoch}',
      topic: url,
      payload: parsedPayload,
      format: format,
      protocol: IoTProtocol.webSocket,
    );

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
