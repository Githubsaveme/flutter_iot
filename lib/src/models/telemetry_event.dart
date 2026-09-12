class TelemetryEvent {
  final String id;
  final String deviceId;
  final String metric;
  final dynamic value;
  final String? unit;
  final String? quality;
  final String? source;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  TelemetryEvent({
    required this.id,
    required this.deviceId,
    required this.metric,
    required this.value,
    this.unit,
    this.quality = 'GOOD',
    this.source,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceId': deviceId,
        'metric': metric,
        'value': value,
        'unit': unit,
        'quality': quality,
        'source': source,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  @override
  String toString() => 'TelemetryEvent(deviceId: $deviceId, metric: $metric, value: $value)';
}
