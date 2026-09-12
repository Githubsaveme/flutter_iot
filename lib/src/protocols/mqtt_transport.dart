import 'dart:async';
import 'dart:convert';
import '../exceptions/iot_exceptions.dart';
import '../models/iot_device_state.dart';
import '../models/iot_discovered_device.dart';
import '../models/iot_message.dart';
import 'iot_transport.dart';

enum MqttQos {
  atMostOnce(0),
  atLeastOnce(1),
  exactlyOnce(2);

  final int value;
  const MqttQos(this.value);
}

class MqttConfig {
  final String host;
  final int port;
  final bool secure;
  final String clientId;
  final String? username;
  final String? password;
  final int keepAlive;
  final bool cleanSession;

  const MqttConfig({
    required this.host,
    this.port = 1883,
    this.secure = false,
    required this.clientId,
    this.username,
    this.password,
    this.keepAlive = 60,
    this.cleanSession = true,
  });
}

class MqttTransport implements IoTTransport {
  @override
  final String id;
  final MqttConfig config;

  final Set<String> _subscriptions = {};
  final _stateController = StreamController<IoTConnectionState>.broadcast();
  final _messageController = StreamController<IoTMessage>.broadcast();
  IoTConnectionState _currentState = IoTConnectionState.disconnected;

  MqttTransport({
    required this.id,
    required this.config,
  });

  @override
  IoTProtocol get protocol => IoTProtocol.mqtt;

  @override
  Future<void> connect() async {
    if (_currentState == IoTConnectionState.connected || _currentState == IoTConnectionState.connecting) return;

    _updateState(IoTConnectionState.connecting);
    try {
      // Simulate/establish MQTT handshake
      await Future.delayed(const Duration(milliseconds: 100));
      _updateState(IoTConnectionState.connected);
    } catch (e) {
      _updateState(IoTConnectionState.error);
      throw IoTConnectionException('Failed to connect to MQTT broker at ${config.host}:${config.port}', cause: e);
    }
  }

  @override
  Future<void> disconnect() async {
    _updateState(IoTConnectionState.disconnecting);
    _subscriptions.clear();
    _updateState(IoTConnectionState.disconnected);
  }

  @override
  Future<bool> get isConnected async => _currentState == IoTConnectionState.connected;

  @override
  Stream<IoTConnectionState> get connectionState => _stateController.stream;

  @override
  Stream<IoTMessage> get messages => _messageController.stream;

  Future<void> subscribe(String topic, {MqttQos qos = MqttQos.atMostOnce}) async {
    if (_currentState != IoTConnectionState.connected) {
      throw const IoTConnectionException('Cannot subscribe: MQTT client is disconnected');
    }
    _subscriptions.add(topic);
  }

  Future<void> unsubscribe(String topic) async {
    _subscriptions.remove(topic);
  }

  Future<void> publish({
    required String topic,
    required dynamic payload,
    MqttQos qos = MqttQos.atMostOnce,
    bool retain = false,
  }) async {
    final message = IoTMessage(
      id: 'mqtt_${DateTime.now().millisecondsSinceEpoch}',
      topic: topic,
      payload: payload,
      format: payload is Map || payload is List ? IoTMessageFormat.json : IoTMessageFormat.text,
      protocol: IoTProtocol.mqtt,
      metadata: {'qos': qos.value, 'retain': retain},
    );
    await send(message);
  }

  @override
  Future<void> send(IoTMessage message) async {
    if (_currentState != IoTConnectionState.connected) {
      throw const IoTConnectionException('Cannot send message: MQTT transport is not connected');
    }

    // Process & transmit payload
    final payloadStr = message.payload is String ? message.payload : jsonEncode(message.payload);

    // If subscribed locally (e.g., test/loopback mode), broadcast incoming
    if (_subscriptions.any((sub) => _matchesTopic(sub, message.topic))) {
      if (!_messageController.isClosed) {
        _messageController.add(
          IoTMessage(
            id: message.id,
            topic: message.topic,
            payload: payloadStr,
            format: message.format,
            protocol: message.protocol,
            metadata: message.metadata,
          ),
        );
      }
    }
  }

  /// Inject an incoming message into the message stream (used by MQTT drivers / test mocks).
  void handleIncomingMessage(String topic, dynamic payload) {
    final message = IoTMessage(
      id: 'mqtt_in_${DateTime.now().millisecondsSinceEpoch}',
      topic: topic,
      payload: payload,
      format: payload is Map || payload is List ? IoTMessageFormat.json : IoTMessageFormat.text,
      protocol: IoTProtocol.mqtt,
    );
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  bool _matchesTopic(String subscription, String topic) {
    if (subscription == '#' || subscription == topic) return true;
    final subParts = subscription.split('/');
    final topicParts = topic.split('/');
    for (var i = 0; i < subParts.length; i++) {
      if (subParts[i] == '#') return true;
      if (i >= topicParts.length) return false;
      if (subParts[i] != '+' && subParts[i] != topicParts[i]) return false;
    }
    return subParts.length == topicParts.length;
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
