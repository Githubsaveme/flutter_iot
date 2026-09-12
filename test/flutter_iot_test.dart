import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iot/flutter_iot.dart';
import 'package:flutter_iot/flutter_iot_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterIotPlatform extends MethodChannelFlutterIot
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getPlatformVersion() async => 'Android 13';

  @override
  Future<String?> checkPermission(String permission) async => 'granted';

  @override
  Future<String?> requestPermission(String permission) async => 'granted';

  @override
  Future<bool> startBleScan({List<String>? serviceUuids}) async => true;

  @override
  Future<bool> stopBleScan() async => true;

  @override
  Future<bool> connectBle(String deviceId) async => true;

  @override
  Future<bool> disconnectBle(String deviceId) async => true;

  @override
  Future<Map<String, dynamic>?> getWifiInfo() async => {'ssid': 'Test_WiFi', 'ip': '192.168.1.10'};

  @override
  Future<bool> startBackgroundMonitoring({
    required int intervalMinutes,
    String? notificationTitle,
    String? notificationBody,
  }) async => true;

  @override
  Future<bool> stopBackgroundMonitoring() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterIotPlatform.instance = MockFlutterIotPlatform();
  });

  test('FlutterIot getPlatformVersion returns platform version', () async {
    final plugin = FlutterIot();
    expect(await plugin.getPlatformVersion(), 'Android 13');
  });

  test('FlutterIoT instance initializes correctly', () async {
    final iot = FlutterIoT.instance;
    await iot.initialize(const IoTConfig(logLevel: IoTLogLevel.debug));

    expect(iot.isInitialized, isTrue);
    expect(iot.capabilities.bluetooth, isTrue);
    expect(iot.capabilities.wifi, isTrue);
  });

  test('IoTDiscoveryManager discovers active network devices', () async {
    final iot = FlutterIoT.instance;
    final devicesStream = iot.scan(protocols: [IoTProtocol.wifi]);

    final devices = await devicesStream.take(1).toList();
    expect(devices.isNotEmpty, isTrue);
  });
}
