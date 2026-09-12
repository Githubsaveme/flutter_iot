import 'iot_discovered_device.dart';

enum IoTMessageFormat {
  json,
  text,
  bytes,
  hex,
}

class IoTMessage {
  final String id;
  final String topic;
  final dynamic payload;
  final IoTMessageFormat format;
  final IoTProtocol protocol;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  IoTMessage({
    required this.id,
    required this.topic,
    required this.payload,
    this.format = IoTMessageFormat.text,
    required this.protocol,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'payload': payload,
        'format': format.name,
        'protocol': protocol.name,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  @override
  String toString() => 'IoTMessage(id: $id, topic: $topic, protocol: ${protocol.name}, format: ${format.name})';
}
