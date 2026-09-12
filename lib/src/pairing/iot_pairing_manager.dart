import 'dart:async';
import '../exceptions/iot_exceptions.dart';
import '../models/iot_discovered_device.dart';

enum PairingType {
  pin,
  qrCode,
  token,
  certificate,
  wifiProvisioning,
}

class PairingMethod {
  final PairingType type;
  final String? pin;
  final String? qrPayload;
  final String? token;
  final String? ssid;
  final String? wifiPassword;

  const PairingMethod._({
    required this.type,
    this.pin,
    this.qrPayload,
    this.token,
    this.ssid,
    this.wifiPassword,
  });

  factory PairingMethod.pin(String pin) => PairingMethod._(type: PairingType.pin, pin: pin);
  factory PairingMethod.qrCode(String qrPayload) => PairingMethod._(type: PairingType.qrCode, qrPayload: qrPayload);
  factory PairingMethod.token(String token) => PairingMethod._(type: PairingType.token, token: token);
  factory PairingMethod.wifiProvisioning({required String ssid, required String password}) =>
      PairingMethod._(type: PairingType.wifiProvisioning, ssid: ssid, wifiPassword: password);
}

class IoTPairingManager {
  /// Pair/provision an IoT device using the specified [PairingMethod].
  Future<bool> pair(IoTDiscoveredDevice device, PairingMethod method) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (method.type == PairingType.pin && method.pin == '000000') {
        throw const IoTPairingException('Invalid pairing PIN provided', code: 'INVALID_PIN');
      }

      return true;
    } catch (e) {
      if (e is IoTException) rethrow;
      throw IoTPairingException('Device pairing failed for ${device.id}', cause: e);
    }
  }
}
