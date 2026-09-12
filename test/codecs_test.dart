import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iot/flutter_iot.dart';

void main() {
  group('IoT Codecs', () {
    test('JsonIoTCodec encodes and decodes JSON', () {
      final codec = JsonIoTCodec();
      final data = {'temperature': 24.5, 'humidity': 60};

      final encoded = codec.encode(data);
      final decoded = codec.decode(encoded);

      expect(decoded['temperature'], equals(24.5));
      expect(decoded['humidity'], equals(60));
    });

    test('HexIoTCodec encodes and decodes hex strings', () {
      final codec = HexIoTCodec();
      final hex = '48656c6c6f'; // "Hello"

      final bytes = codec.encode(hex);
      final decodedHex = codec.decode(bytes);

      expect(decodedHex, equals(hex));
    });

    test('Base64IoTCodec encodes and decodes base64 strings', () {
      final codec = Base64IoTCodec();
      final b64 = 'SGVsbG8gSU9U';

      final bytes = codec.encode(b64);
      final decoded = codec.decode(bytes);

      expect(decoded, equals(b64));
    });
  });
}
