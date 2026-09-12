import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../exceptions/iot_exceptions.dart';
import '../models/iot_device_state.dart';
import '../models/iot_discovered_device.dart';
import '../models/iot_message.dart';
import 'iot_transport.dart';

class UdpTransport implements IoTTransport {
  @override
  final String id;
  final int bindPort;
  RawDatagramSocket? _socket;
  StreamSubscription? _subscription;

  final _stateController = StreamController<IoTConnectionState>.broadcast();
  final _messageController = StreamController<IoTMessage>.broadcast();
  IoTConnectionState _currentState = IoTConnectionState.disconnected;

  UdpTransport({
    required this.id,
    this.bindPort = 0,
  });

  @override
  IoTProtocol get protocol => IoTProtocol.udp;

  @override
  Future<void> connect() async {
    if (_currentState == IoTConnectionState.connected) return;

    _updateState(IoTConnectionState.connecting);
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, bindPort);
      _socket!.broadcastEnabled = true;

      _subscription = _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            final message = IoTMessage(
              id: 'udp_${DateTime.now().millisecondsSinceEpoch}',
              topic: '${datagram.address.address}:${datagram.port}',
              payload: datagram.data,
              format: IoTMessageFormat.bytes,
              protocol: IoTProtocol.udp,
              metadata: {
                'address': datagram.address.address,
                'port': datagram.port,
              },
            );
            if (!_messageController.isClosed) {
              _messageController.add(message);
            }
          }
        }
      });

      _updateState(IoTConnectionState.connected);
    } catch (e) {
      _updateState(IoTConnectionState.error);
      throw IoTConnectionException('Failed to bind UDP socket on port $bindPort', cause: e);
    }
  }

  @override
  Future<void> disconnect() async {
    _updateState(IoTConnectionState.disconnecting);
    await _subscription?.cancel();
    _subscription = null;
    _socket?.close();
    _socket = null;
    _updateState(IoTConnectionState.disconnected);
  }

  @override
  Future<bool> get isConnected async => _currentState == IoTConnectionState.connected;

  @override
  Stream<IoTConnectionState> get connectionState => _stateController.stream;

  @override
  Stream<IoTMessage> get messages => _messageController.stream;

  Future<void> sendTo({
    required String host,
    required int port,
    required List<int> data,
  }) async {
    if (_socket == null) {
      await connect();
    }

    try {
      final targetAddress = host == '255.255.255.255'
          ? InternetAddress('255.255.255.255')
          : (await InternetAddress.lookup(host)).first;

      _socket!.send(data, targetAddress, port);
    } catch (e) {
      throw IoTNetworkException('Failed to send UDP datagram to $host:$port', cause: e);
    }
  }

  @override
  Future<void> send(IoTMessage message) async {
    final host = message.metadata['host'] ?? '255.255.255.255';
    final port = message.metadata['port'] ?? 4210;
    final data = message.payload is List<int>
        ? message.payload as List<int>
        : Uint8List.fromList(message.payload.toString().codeUnits);

    await sendTo(host: host, port: port, data: data);
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
