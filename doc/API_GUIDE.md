# Flutter IoT SDK API Guide

## 1. Initialization

```dart
import 'package:flutter_iot/flutter_iot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterIoT.instance.initialize(
    const IoTConfig(
      enableLogging: true,
      logLevel: IoTLogLevel.info,
      autoReconnect: true,
    ),
  );
}
```

## 2. Multi-Protocol Scanning

```dart
final iot = FlutterIoT.instance;

// Request required BLE permissions before scanning
await iot.permissions.ensureBlePermissions();

final scanStream = iot.scan(
  protocols: [IoTProtocol.ble, IoTProtocol.mdns, IoTProtocol.udp],
  timeout: const Duration(seconds: 10),
);

scanStream.listen((device) {
  print('Discovered: ${device.name} (${device.id}) via ${device.protocol}');
});
```

## 3. BLE Central Connection

```dart
final ble = iot.ble(deviceId: 'AA:BB:CC:DD:EE:FF');
await ble.connect();

final services = await ble.discoverServices();
final batteryBytes = await ble.readCharacteristic(
  serviceUuid: '0000180f-0000-1000-8000-00805f9b34fb',
  characteristicUuid: '00002a19-0000-1000-8000-00805f9b34fb',
);
print('Battery Level: ${batteryBytes.first}%');
```

## 4. MQTT Pub/Sub Connection

```dart
final mqtt = iot.mqtt(
  const MqttConfig(
    host: 'broker.hivemq.com',
    port: 1883,
    clientId: 'flutter_iot_device_100',
  ),
);

await mqtt.connect();
await mqtt.subscribe('home/livingroom/temp');

mqtt.messages.listen((msg) {
  print('Topic: ${msg.topic}, Payload: ${msg.payload}');
});
```

## 5. Custom Device Adapters

```dart
class SmartBulbAdapter extends IoTDeviceAdapter {
  @override
  String get adapterId => 'smart_bulb_v1';

  @override
  bool supports(IoTDiscoveredDevice device) => device.name?.contains('SmartBulb') ?? false;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<dynamic> execute(IoTCommand command) async {
    return true;
  }

  @override
  Stream<IoTDeviceState> get stateStream => Stream.empty();
}

// Register custom adapter
iot.registerAdapter(SmartBulbAdapter());
```
