enum IoTConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  reconnecting,
  error,
}

class IoTDeviceState {
  final bool online;
  final IoTConnectionState connectionState;
  final DateTime? lastSeen;
  final Map<String, dynamic> values;

  const IoTDeviceState({
    this.online = false,
    this.connectionState = IoTConnectionState.disconnected,
    this.lastSeen,
    this.values = const {},
  });

  IoTDeviceState copyWith({
    bool? online,
    IoTConnectionState? connectionState,
    DateTime? lastSeen,
    Map<String, dynamic>? values,
  }) {
    return IoTDeviceState(
      online: online ?? this.online,
      connectionState: connectionState ?? this.connectionState,
      lastSeen: lastSeen ?? this.lastSeen,
      values: values ?? this.values,
    );
  }

  Map<String, dynamic> toJson() => {
        'online': online,
        'connectionState': connectionState.name,
        'lastSeen': lastSeen?.toIso8601String(),
        'values': values,
      };

  @override
  String toString() => 'IoTDeviceState(online: $online, state: ${connectionState.name}, values: $values)';
}
