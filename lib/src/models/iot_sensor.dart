enum SensorType {
  temperature,
  humidity,
  pressure,
  light,
  proximity,
  motion,
  accelerometer,
  gyroscope,
  magnetometer,
  battery,
  voltage,
  current,
  power,
  co2,
  airQuality,
  gps,
  waterLevel,
  soilMoisture,
  sound,
  gas,
  door,
  window,
  switchRelay,
  custom,
}

class IoTSensor<T> {
  final String id;
  final SensorType type;
  final String? unit;
  final T? value;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  IoTSensor({
    required this.id,
    required this.type,
    this.unit,
    this.value,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'unit': unit,
        'value': value,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  @override
  String toString() => 'IoTSensor<$T>(id: $id, type: ${type.name}, value: $value ${unit ?? ""})';
}
