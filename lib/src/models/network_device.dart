import 'dart:io';

class NetworkDevice {
  final String id;
  final String? name;
  final InternetAddress address;
  final int? port;
  final String? service;
  final Map<String, dynamic> metadata;

  const NetworkDevice({
    required this.id,
    this.name,
    required this.address,
    this.port,
    this.service,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address.address,
        'port': port,
        'service': service,
        'metadata': metadata,
      };

  @override
  String toString() => 'NetworkDevice(id: $id, name: $name, address: ${address.address}:$port)';
}
