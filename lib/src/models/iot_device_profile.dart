import '../capabilities/iot_feature.dart';

class IoTDeviceProfile {
  final String id;
  final String? manufacturer;
  final String? model;
  final String? firmwareVersion;
  final String type;
  final List<IoTFeature> capabilities;
  final Map<String, dynamic> metadata;

  const IoTDeviceProfile({
    required this.id,
    this.manufacturer,
    this.model,
    this.firmwareVersion,
    required this.type,
    this.capabilities = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'manufacturer': manufacturer,
        'model': model,
        'firmwareVersion': firmwareVersion,
        'type': type,
        'capabilities': capabilities.map((c) => c.name).toList(),
        'metadata': metadata,
      };

  @override
  String toString() => 'IoTDeviceProfile(id: $id, model: $model, firmware: $firmwareVersion)';
}
