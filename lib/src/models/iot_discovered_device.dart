enum IoTProtocol {
  ble,
  wifi,
  mqtt,
  webSocket,
  http,
  tcp,
  udp,
  mdns,
}

class IoTDiscoveredDevice {
  final String id;
  final String? name;
  final IoTProtocol protocol;
  final String type;
  final String? address;
  final int? port;
  final int? rssi;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  IoTDiscoveredDevice({
    required this.id,
    this.name,
    required this.protocol,
    required this.type,
    this.address,
    this.port,
    this.rssi,
    this.metadata = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'protocol': protocol.name,
        'type': type,
        'address': address,
        'port': port,
        'rssi': rssi,
        'metadata': metadata,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() => 'IoTDiscoveredDevice(id: $id, name: $name, protocol: ${protocol.name}, type: $type)';
}
