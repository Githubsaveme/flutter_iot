# Flutter IoT SDK Architecture Guide

## Overview

`flutter_iot` is built with Clean Architecture, separating the public Dart API layer, domain models, protocol transports, platform abstraction interface, and platform-specific native channel implementations.

```text
                      FLUTTER APPLICATION
                               │
                               ▼
                    ┌─────────────────────┐
                    │   FlutterIoT Facade │
                    │                     │
                    │  BLE                │
                    │  Wi-Fi              │
                    │  MQTT               │
                    │  WebSocket          │
                    │  HTTP               │
                    │  TCP                │
                    │  UDP                │
                    │  Discovery          │
                    │  Permissions        │
                    │  Capabilities       │
                    └──────────┬──────────┘
                               │
                               ▼
                   PLATFORM INTERFACE BRIDGE
                               │
         ┌─────────────────────┼─────────────────────┐
         ▼                     ▼                     ▼
     Android                 iOS                 Desktop / Web
   Kotlin Plugin         Swift Plugin         Native C++ / JS
```

## Layer Descriptions

1. **Facade Layer (`FlutterIoT` / `IoTManager`)**:
   Provides a clean access point for all IoT services.

2. **Models Layer (`IoTDevice`, `IoTMessage`, `IoTCommand`, `IoTSensor`, `TelemetryEvent`)**:
   Unified, immutable data models shared across all platforms.

3. **Protocol Layer (`IoTTransport`, `BleTransport`, `MqttTransport`, `HttpTransport`, `WebSocketTransport`, `TcpTransport`, `UdpTransport`)**:
   Protocol-specific communication drivers conforming to `IoTTransport`.

4. **Capabilities & Permissions Layer (`IoTCapabilities`, `IoTPermissionsManager`)**:
   Runtime detection for OS features and feature-specific permission checking (`ensureBlePermissions()`, `ensureWifiPermissions()`).

5. **Platform Bridge Layer (`FlutterIotPlatform`, `MethodChannelFlutterIot`)**:
   Decouples Dart business logic from native platform code.
