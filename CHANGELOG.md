# 0.0.1

- Initial release of `flutter_iot`.
- Unified IoT API facade (`FlutterIoT.instance` / `IoTManager`).
- Multi-protocol transports: BLE, Wi-Fi, MQTT, WebSocket, HTTP/REST, TCP, UDP.
- Device discovery engine supporting BLE, mDNS, and UDP scanning.
- Typed exception hierarchy (`IoTException`), models (`IoTMessage`, `IoTCommand`, `IoTSensor`, `TelemetryEvent`, `BleDevice`, `NetworkDevice`).
- Security ready logging with automatic credential redaction.
- Capability detection & permission management system.
- Offline command buffering & exponential backoff reconnect policy.
- Custom `IoTDeviceAdapter` extension system.
- Android Kotlin and iOS Swift native method channel integration.
- Complete Material 3 example control center application.
