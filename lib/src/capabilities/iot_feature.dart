/// Protocol and device capabilities that can be checked at runtime.
enum IoTFeature {
  bleCentral,
  blePeripheral,
  bleBackground,
  bleAdvertising,
  wifiSsid,
  wifiDiscovery,
  mqtt,
  webSocket,
  http,
  tcp,
  udp,
  mDNS,
  backgroundMonitoring,
  secureStorage,
}
