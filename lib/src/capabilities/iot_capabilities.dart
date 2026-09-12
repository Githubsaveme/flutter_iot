import 'iot_feature.dart';

/// Represents runtime capability detection for the current platform and device.
class IoTCapabilities {
  final String platform;
  final bool bluetooth;
  final bool bleAdvertising;
  final bool backgroundBle;
  final bool wifi;
  final bool wifiSsid;
  final bool mqtt;
  final bool webSocket;
  final bool http;
  final bool tcp;
  final bool udp;
  final bool mDNS;
  final bool backgroundMonitoring;
  final bool secureStorage;

  const IoTCapabilities({
    required this.platform,
    required this.bluetooth,
    required this.bleAdvertising,
    required this.backgroundBle,
    required this.wifi,
    required this.wifiSsid,
    required this.mqtt,
    required this.webSocket,
    required this.http,
    required this.tcp,
    required this.udp,
    required this.mDNS,
    required this.backgroundMonitoring,
    required this.secureStorage,
  });

  /// Factory constructor to generate fallback platform default capabilities.
  factory IoTCapabilities.forPlatform(String platform) {
    final isWeb = platform == 'web';
    final isAndroid = platform.toLowerCase().contains('android');
    final isIOS = platform.toLowerCase().contains('ios');
    final isDesktop = platform.toLowerCase().contains('windows') ||
        platform.toLowerCase().contains('macos') ||
        platform.toLowerCase().contains('linux');

    return IoTCapabilities(
      platform: platform,
      bluetooth: !isWeb,
      bleAdvertising: isAndroid || isIOS,
      backgroundBle: isAndroid || isIOS,
      wifi: true,
      wifiSsid: isAndroid || isIOS,
      mqtt: true,
      webSocket: true,
      http: true,
      tcp: !isWeb,
      udp: !isWeb,
      mDNS: !isWeb,
      backgroundMonitoring: isAndroid || isIOS || isDesktop,
      secureStorage: true,
    );
  }

  /// Check whether a specific [IoTFeature] is supported by this runtime environment.
  bool supports(IoTFeature feature) {
    switch (feature) {
      case IoTFeature.bleCentral:
        return bluetooth;
      case IoTFeature.blePeripheral:
      case IoTFeature.bleAdvertising:
        return bleAdvertising;
      case IoTFeature.bleBackground:
        return backgroundBle;
      case IoTFeature.wifiSsid:
        return wifiSsid;
      case IoTFeature.wifiDiscovery:
        return wifi;
      case IoTFeature.mqtt:
        return mqtt;
      case IoTFeature.webSocket:
        return webSocket;
      case IoTFeature.http:
        return http;
      case IoTFeature.tcp:
        return tcp;
      case IoTFeature.udp:
        return udp;
      case IoTFeature.mDNS:
        return mDNS;
      case IoTFeature.backgroundMonitoring:
        return backgroundMonitoring;
      case IoTFeature.secureStorage:
        return secureStorage;
    }
  }

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'bluetooth': bluetooth,
        'bleAdvertising': bleAdvertising,
        'backgroundBle': backgroundBle,
        'wifi': wifi,
        'wifiSsid': wifiSsid,
        'mqtt': mqtt,
        'webSocket': webSocket,
        'http': http,
        'tcp': tcp,
        'udp': udp,
        'mDNS': mDNS,
        'backgroundMonitoring': backgroundMonitoring,
        'secureStorage': secureStorage,
      };

  @override
  String toString() => 'IoTCapabilities($platform: BLE=$bluetooth, Wi-Fi=$wifi, MQTT=$mqtt, WebSockets=$webSocket)';
}
