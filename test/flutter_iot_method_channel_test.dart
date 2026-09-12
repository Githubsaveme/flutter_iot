import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iot/flutter_iot_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelFlutterIot platform = MethodChannelFlutterIot();
  const MethodChannel channel = MethodChannel('flutter_iot');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'getPlatformVersion':
          return 'Android 14';
        case 'checkPermission':
        case 'requestPermission':
          return 'granted';
        case 'startBleScan':
        case 'stopBleScan':
        case 'connectBle':
        case 'disconnectBle':
        case 'startBackgroundMonitoring':
        case 'stopBackgroundMonitoring':
          return true;
        case 'getWifiInfo':
          return {'ssid': 'Mock_WiFi', 'ip': '192.168.1.50'};
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion returns mock platform string', () async {
    expect(await platform.getPlatformVersion(), 'Android 14');
  });

  test('checkPermission returns granted', () async {
    expect(await platform.checkPermission('bluetooth'), 'granted');
  });

  test('getWifiInfo returns map', () async {
    final info = await platform.getWifiInfo();
    expect(info?['ssid'], 'Mock_WiFi');
  });
}
