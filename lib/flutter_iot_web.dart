// ignore: avoid_web_libraries_in_flutter
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'flutter_iot_platform_interface.dart';

/// A web implementation of the FlutterIotPlatform for the FlutterIot plugin.
class FlutterIotWeb extends FlutterIotPlatform {
  FlutterIotWeb();

  static void registerWith(Registrar registrar) {
    FlutterIotPlatform.instance = FlutterIotWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return 'Web (${web.window.navigator.userAgent})';
  }

  @override
  Future<String?> checkPermission(String permission) async {
    return 'granted';
  }

  @override
  Future<String?> requestPermission(String permission) async {
    return 'granted';
  }

  @override
  Future<bool> startBleScan({List<String>? serviceUuids}) async {
    return false;
  }

  @override
  Future<bool> stopBleScan() async {
    return true;
  }

  @override
  Future<bool> connectBle(String deviceId) async {
    return false;
  }

  @override
  Future<bool> disconnectBle(String deviceId) async {
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getWifiInfo() async {
    return {
      'ssid': 'Browser_Web_Network',
      'ip': '127.0.0.1',
    };
  }

  @override
  Future<bool> startBackgroundMonitoring({
    required int intervalMinutes,
    String? notificationTitle,
    String? notificationBody,
  }) async {
    return false;
  }

  @override
  Future<bool> stopBackgroundMonitoring() async {
    return true;
  }
}
