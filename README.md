# Flutter IoT SDK (`flutter_iot`)

[![pub package](https://img.shields.io/pub/v/flutter_iot.svg)](https://pub.dev/packages/flutter_iot)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A production-ready, modular, and extensible Flutter IoT Plugin providing a unified Dart API for IoT device communication across multiple protocols including **BLE**, **Wi-Fi**, **MQTT**, **WebSocket**, **HTTP/REST**, **TCP**, and **UDP**.

Designed with **Clean Architecture**, **Federated Plugin Abstractions**, and **Platform-Aware Capability Detection**.

---

## 🌟 Key Features

- 📶 **Multi-Protocol Transports**: Unified abstractions for BLE, MQTT, WebSocket, HTTP, TCP, UDP, and Wi-Fi.
- 🔍 **Unified Device Discovery**: Concurrent multi-protocol scanner aggregating BLE, mDNS/DNS-SD, and UDP broadcast.
- ⚡ **Type-Safe API**: Sealed exception hierarchy (`IoTException`), typed commands (`IoTCommand`), sensors (`IoTSensor`), and telemetry (`TelemetryEvent`).
- 🔐 **Security Ready**: Secure storage abstractions, certificate pinning hooks, and automatic credential redaction in diagnostic logs.
- 🔋 **Power & Battery Aware**: Power policies (`IoTPowerPolicy`), scan duty cycling, and battery optimization modes.
- 🔄 **Reconnection & Offline Queue**: Exponential backoff with jitter (`ReconnectPolicy`) and offline command buffering (`OfflineQueue`).
- 🧩 **Custom Device Adapter Architecture**: Build third-party device/manufacturer plugins without touching core package code.
- 📱 **Cross-Platform**: Android, iOS, Web, Windows, macOS, and Linux.

---

## 📊 Platform Feature Matrix

| Feature | Android | iOS | Web | Windows | macOS | Linux |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **BLE Central** | Full | Full | Web BLE | Full | Full | Full |
| **Wi-Fi Discovery** | Full | OS Restricted | Restricted | Full | Full | Full |
| **MQTT** | Full | Full | WebSocket | Full | Full | Full |
| **WebSocket** | Full | Full | Full | Full | Full | Full |
| **HTTP / REST** | Full | Full | Full | Full | Full | Full |
| **TCP Sockets** | Full | Full | Restricted | Full | Full | Full |
| **UDP Datagrams** | Full | Full | Restricted | Full | Full | Full |
| **mDNS / DNS-SD** | Full | Full | Restricted | Full | Full | Full |
| **Background Monitoring** | Full | Restricted | N/A | Full | Full | Full |

---

## 🚀 Getting Started

### Installation

Add `flutter_iot` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_iot: ^0.0.1
```

### Initialization

Initialize `FlutterIoT` early in `main()`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_iot/flutter_iot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FlutterIoT.instance.initialize(
    const IoTConfig(
      enableLogging: true,
      logLevel: IoTLogLevel.info,
      autoReconnect: true,
      reconnectPolicy: ReconnectPolicy(
        maxAttempts: 10,
        initialDelay: Duration(seconds: 1),
        maxDelay: Duration(minutes: 1),
      ),
    ),
  );

  runApp(const MyApp());
}
```

---

## 💻 Usage Examples

### 1. Bluetooth Low Energy (BLE)

```dart
final iot = FlutterIoT.instance;

// Scan for BLE peripherals
final scanStream = iot.scan(
  protocols: [IoTProtocol.ble],
  timeout: const Duration(seconds: 10),
);

scanStream.listen((device) {
  print('Discovered BLE Device: ${device.name} (${device.id}) RSSI: ${device.rssi}');
});

// Connect to BLE device & read characteristic
final bleDevice = iot.ble(deviceId: 'AA:BB:CC:DD:EE:FF');
await bleDevice.connect();

final services = await bleDevice.discoverServices();
final value = await bleDevice.readCharacteristic(
  serviceUuid: '0000180f-0000-1000-8000-00805f9b34fb',
  characteristicUuid: '00002a19-0000-1000-8000-00805f9b34fb',
);
```

### 2. MQTT Transport

```dart
final mqtt = iot.mqtt(
  const MqttConfig(
    host: 'broker.example.com',
    port: 1883,
    clientId: 'flutter_iot_client_001',
    username: 'user',
    password: 'secret_password',
  ),
);

await mqtt.connect();
await mqtt.subscribe('home/livingroom/temperature');

mqtt.messages.listen((message) {
  print('Received MQTT topic: ${message.topic}, payload: ${message.payload}');
});

// Publish telemetry
await mqtt.publish(
  topic: 'home/livingroom/light/set',
  payload: {'state': true, 'brightness': 80},
  qos: MqttQos.atLeastOnce,
);
```

### 3. Wi-Fi & mDNS Local Discovery

```dart
final wifiInfo = await iot.wifi.getWifiInfo();
print('Connected Wi-Fi SSID: ${wifiInfo["ssid"]} IP: ${wifiInfo["ip"]}');

// Multi-protocol device scanner
iot.scan(protocols: [IoTProtocol.mdns, IoTProtocol.udp]).listen((discoveredDevice) {
  print('Found Local IoT Device: ${discoveredDevice.name} at ${discoveredDevice.address}:${discoveredDevice.port}');
});
```

### 4. Custom Device Adapter System

Extend `IoTDeviceAdapter` to create domain-specific device drivers:

```dart
class SmartBulbAdapter extends IoTDeviceAdapter {
  @override
  String get adapterId => 'smart_bulb_v1';

  @override
  bool supports(IoTDiscoveredDevice device) => device.name?.contains('SmartBulb') ?? false;

  @override
  Future<void> connect() async { /* Custom handshake */ }

  @override
  Future<void> disconnect() async { /* Custom disconnect */ }

  @override
  Future<dynamic> execute(IoTCommand command) async {
    // Process command
  }

  @override
  Stream<IoTDeviceState> get stateStream => Stream.empty();
}

// Register adapter
FlutterIoT.instance.registerAdapter(SmartBulbAdapter());
```

---

## 🛡️ Exception Handling

`flutter_iot` uses typed exception classes for pattern-matching:

```dart
try {
  await bleDevice.connect();
} on IoTPermissionException catch (e) {
  print('Permission missing: ${e.permission}');
} on IoTConnectionException catch (e) {
  print('Connection failed: ${e.message}');
} on IoTTimeoutException catch (e) {
  print('Operation timed out after ${e.timeout}');
} on IoTException catch (e) {
  print('Generic IoT Error [${e.code}]: ${e.message}');
}
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
