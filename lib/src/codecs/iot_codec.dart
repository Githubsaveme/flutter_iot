import 'dart:convert';
import 'dart:typed_data';
import '../exceptions/iot_exceptions.dart';

abstract class IoTCodec<T> {
  Uint8List encode(T data);
  T decode(Uint8List bytes);
}

class JsonIoTCodec extends IoTCodec<dynamic> {
  @override
  Uint8List encode(dynamic data) {
    try {
      final jsonString = jsonEncode(data);
      return Uint8List.fromList(utf8.encode(jsonString));
    } catch (e, st) {
      throw IoTSerializationException('Failed to encode JSON payload', cause: e, details: {'stackTrace': st.toString()});
    }
  }

  @override
  dynamic decode(Uint8List bytes) {
    try {
      final jsonString = utf8.decode(bytes);
      return jsonDecode(jsonString);
    } catch (e, st) {
      throw IoTSerializationException('Failed to decode JSON payload', cause: e, details: {'stackTrace': st.toString()});
    }
  }
}

class Utf8IoTCodec extends IoTCodec<String> {
  @override
  Uint8List encode(String data) {
    return Uint8List.fromList(utf8.encode(data));
  }

  @override
  String decode(Uint8List bytes) {
    return utf8.decode(bytes);
  }
}

class HexIoTCodec extends IoTCodec<String> {
  @override
  Uint8List encode(String hexString) {
    final cleanHex = hexString.replaceAll(RegExp(r'\s+'), '');
    final bytes = <int>[];
    for (var i = 0; i < cleanHex.length; i += 2) {
      bytes.add(int.parse(cleanHex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  @override
  String decode(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

class Base64IoTCodec extends IoTCodec<String> {
  @override
  Uint8List encode(String base64string) {
    return base64Decode(base64string);
  }

  @override
  String decode(Uint8List bytes) {
    return base64Encode(bytes);
  }
}

class BytesIoTCodec extends IoTCodec<Uint8List> {
  @override
  Uint8List encode(Uint8List data) => data;

  @override
  Uint8List decode(Uint8List bytes) => bytes;
}
