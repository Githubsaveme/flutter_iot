import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/iot_exceptions.dart';
import '../models/iot_device_state.dart';
import '../models/iot_discovered_device.dart';
import '../models/iot_message.dart';
import 'iot_transport.dart';

class HttpTransport implements IoTTransport {
  @override
  final String id;
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final http.Client _client;

  final _stateController = StreamController<IoTConnectionState>.broadcast();
  final _messageController = StreamController<IoTMessage>.broadcast();
  IoTConnectionState _currentState = IoTConnectionState.disconnected;

  HttpTransport({
    required this.id,
    required this.baseUrl,
    Map<String, String>? defaultHeaders,
    http.Client? client,
  })  : defaultHeaders = defaultHeaders ?? {'Content-Type': 'application/json'},
        _client = client ?? http.Client();

  @override
  IoTProtocol get protocol => IoTProtocol.http;

  @override
  Future<void> connect() async {
    _updateState(IoTConnectionState.connected);
  }

  @override
  Future<void> disconnect() async {
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
    final url = Uri.parse(message.topic.startsWith('http') ? message.topic : '$baseUrl/${message.topic}');
    final headers = {...defaultHeaders};

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: message.payload is String ? message.payload : jsonEncode(message.payload),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw IoTConnectionException(
          'HTTP request failed with status code ${response.statusCode}',
          code: 'HTTP_${response.statusCode}',
          details: {'body': response.body},
        );
      }
    } catch (e, st) {
      if (e is IoTException) rethrow;
      throw IoTNetworkException('Failed to send HTTP message', cause: e, details: {'stackTrace': st.toString()});
    }
  }

  Future<http.Response> get(String path, {Map<String, String>? headers, Duration timeout = const Duration(seconds: 10)}) async {
    final url = Uri.parse(path.startsWith('http') ? path : '$baseUrl/$path');
    try {
      return await _client.get(url, headers: {...defaultHeaders, ...?headers}).timeout(timeout);
    } catch (e) {
      throw IoTNetworkException('HTTP GET failed on $path', cause: e);
    }
  }

  Future<http.Response> post(String path, {dynamic body, Map<String, String>? headers, Duration timeout = const Duration(seconds: 10)}) async {
    final url = Uri.parse(path.startsWith('http') ? path : '$baseUrl/$path');
    try {
      final payloadStr = body is String ? body : (body != null ? jsonEncode(body) : null);
      return await _client.post(url, headers: {...defaultHeaders, ...?headers}, body: payloadStr).timeout(timeout);
    } catch (e) {
      throw IoTNetworkException('HTTP POST failed on $path', cause: e);
    }
  }

  Future<http.Response> put(String path, {dynamic body, Map<String, String>? headers, Duration timeout = const Duration(seconds: 10)}) async {
    final url = Uri.parse(path.startsWith('http') ? path : '$baseUrl/$path');
    try {
      final payloadStr = body is String ? body : (body != null ? jsonEncode(body) : null);
      return await _client.put(url, headers: {...defaultHeaders, ...?headers}, body: payloadStr).timeout(timeout);
    } catch (e) {
      throw IoTNetworkException('HTTP PUT failed on $path', cause: e);
    }
  }

  Future<http.Response> delete(String path, {Map<String, String>? headers, Duration timeout = const Duration(seconds: 10)}) async {
    final url = Uri.parse(path.startsWith('http') ? path : '$baseUrl/$path');
    try {
      return await _client.delete(url, headers: {...defaultHeaders, ...?headers}).timeout(timeout);
    } catch (e) {
      throw IoTNetworkException('HTTP DELETE failed on $path', cause: e);
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
    _client.close();
    await _stateController.close();
    await _messageController.close();
  }
}
