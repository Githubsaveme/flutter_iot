enum IoTCommandStatus {
  pending,
  sent,
  acknowledged,
  completed,
  failed,
  timeout,
  cancelled,
}

class IoTCommand {
  final String id;
  final String name;
  final Map<String, dynamic> payload;
  final Duration timeout;
  final bool queueIfOffline;
  final IoTCommandStatus status;
  final String correlationId;
  final DateTime timestamp;
  final String? error;

  IoTCommand({
    required this.id,
    required this.name,
    this.payload = const {},
    this.timeout = const Duration(seconds: 10),
    this.queueIfOffline = true,
    this.status = IoTCommandStatus.pending,
    String? correlationId,
    DateTime? timestamp,
    this.error,
  })  : correlationId = correlationId ?? '${id}_${DateTime.now().millisecondsSinceEpoch}',
        timestamp = timestamp ?? DateTime.now();

  IoTCommand copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? payload,
    Duration? timeout,
    bool? queueIfOffline,
    IoTCommandStatus? status,
    String? correlationId,
    DateTime? timestamp,
    String? error,
  }) {
    return IoTCommand(
      id: id ?? this.id,
      name: name ?? this.name,
      payload: payload ?? this.payload,
      timeout: timeout ?? this.timeout,
      queueIfOffline: queueIfOffline ?? this.queueIfOffline,
      status: status ?? this.status,
      correlationId: correlationId ?? this.correlationId,
      timestamp: timestamp ?? this.timestamp,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'payload': payload,
        'timeoutMs': timeout.inMilliseconds,
        'queueIfOffline': queueIfOffline,
        'status': status.name,
        'correlationId': correlationId,
        'timestamp': timestamp.toIso8601String(),
        'error': error,
      };

  @override
  String toString() => 'IoTCommand(id: $id, name: $name, status: ${status.name})';
}
