import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'flutter_iot_platform_interface.dart';
import 'src/models/ble_device.dart';

class MethodChannelFlutterIot extends FlutterIotPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_iot');

  final _bleDiscoveredController = StreamController<BleDevice>.broadcast();
  final _bleStateController = StreamController<Map<String, dynamic>>.broadcast();

  MethodChannelFlutterIot() {
    methodChannel.setMethodCallHandler(_handleNativeCall);
  }

  Stream<BleDevice> get onBleDeviceDiscovered => _bleDiscoveredController.stream;
  Stream<Map<String, dynamic>> get onBleStateChange => _bleStateController.stream;

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onBleDeviceDiscovered':
        final map = Map<String, dynamic>.from(call.arguments as Map);
        final device = BleDevice(
          id: map['id'] as String? ?? 'unknown',
          name: map['name'] as String? ?? 'BLE Device',
          rssi: map['rssi'] as int? ?? -60,
        );
        if (!_bleDiscoveredController.isClosed) {
          _bleDiscoveredController.add(device);
        }
        break;
      case 'onBleStateChange':
      case 'onBluetoothStateChanged':
        final map = Map<String, dynamic>.from(call.arguments as Map);
        if (!_bleStateController.isClosed) {
          _bleStateController.add(map);
        }
        break;
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    return await methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<String?> checkPermission(String permission) async {
    return await methodChannel.invokeMethod<String>('checkPermission', {'permission': permission});
  }

  @override
  Future<String?> requestPermission(String permission) async {
    return await methodChannel.invokeMethod<String>('requestPermission', {'permission': permission});
  }

  @override
  Future<bool> startBleScan({List<String>? serviceUuids}) async {
    final result = await methodChannel.invokeMethod<bool>('startBleScan', {'serviceUuids': serviceUuids});
    return result ?? false;
  }

  @override
  Future<bool> stopBleScan() async {
    final result = await methodChannel.invokeMethod<bool>('stopBleScan');
    return result ?? false;
  }

  @override
  Future<bool> connectBle(String deviceId) async {
    final result = await methodChannel.invokeMethod<bool>('connectBle', {'deviceId': deviceId});
    return result ?? false;
  }

  @override
  Future<bool> disconnectBle(String deviceId) async {
    final result = await methodChannel.invokeMethod<bool>('disconnectBle', {'deviceId': deviceId});
    return result ?? false;
  }

  @override
  Future<Map<String, dynamic>?> getWifiInfo() async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('getWifiInfo');
    return result;
  }

  @override
  Future<bool> startBackgroundMonitoring({
    required int intervalMinutes,
    String? notificationTitle,
    String? notificationBody,
  }) async {
    final result = await methodChannel.invokeMethod<bool>('startBackgroundMonitoring', {
      'intervalMinutes': intervalMinutes,
      'notificationTitle': notificationTitle,
      'notificationBody': notificationBody,
    });
    return result ?? false;
  }

  @override
  Future<bool> stopBackgroundMonitoring() async {
    final result = await methodChannel.invokeMethod<bool>('stopBackgroundMonitoring');
    return result ?? false;
  }
}
