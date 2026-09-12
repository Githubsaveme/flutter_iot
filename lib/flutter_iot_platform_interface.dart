import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_iot_method_channel.dart';

abstract class FlutterIotPlatform extends PlatformInterface {
  FlutterIotPlatform() : super(token: _token);

  static final Object _token = Object();
  static FlutterIotPlatform _instance = MethodChannelFlutterIot();

  static FlutterIotPlatform get instance => _instance;

  static set instance(FlutterIotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  Future<String?> checkPermission(String permission) {
    throw UnimplementedError('checkPermission() has not been implemented.');
  }

  Future<String?> requestPermission(String permission) {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  Future<bool> startBleScan({List<String>? serviceUuids}) {
    throw UnimplementedError('startBleScan() has not been implemented.');
  }

  Future<bool> stopBleScan() {
    throw UnimplementedError('stopBleScan() has not been implemented.');
  }

  Future<bool> connectBle(String deviceId) {
    throw UnimplementedError('connectBle() has not been implemented.');
  }

  Future<bool> disconnectBle(String deviceId) {
    throw UnimplementedError('disconnectBle() has not been implemented.');
  }

  Future<Map<String, dynamic>?> getWifiInfo() {
    throw UnimplementedError('getWifiInfo() has not been implemented.');
  }

  Future<bool> startBackgroundMonitoring({
    required int intervalMinutes,
    String? notificationTitle,
    String? notificationBody,
  }) {
    throw UnimplementedError('startBackgroundMonitoring() has not been implemented.');
  }

  Future<bool> stopBackgroundMonitoring() {
    throw UnimplementedError('stopBackgroundMonitoring() has not been implemented.');
  }
}
