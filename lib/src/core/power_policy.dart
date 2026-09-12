enum BackgroundMode {
  disabled,
  opportunistic,
  continuous,
}

class IoTPowerPolicy {
  final Duration scanInterval;
  final Duration scanDuration;
  final double reconnectAggressiveness;
  final BackgroundMode backgroundMode;
  final bool lowBatteryOptimization;

  const IoTPowerPolicy({
    this.scanInterval = const Duration(minutes: 1),
    this.scanDuration = const Duration(seconds: 10),
    this.reconnectAggressiveness = 1.0,
    this.backgroundMode = BackgroundMode.opportunistic,
    this.lowBatteryOptimization = true,
  });

  static const IoTPowerPolicy highPerformance = IoTPowerPolicy(
    scanInterval: Duration(seconds: 10),
    scanDuration: Duration(seconds: 10),
    reconnectAggressiveness: 2.0,
    backgroundMode: BackgroundMode.continuous,
    lowBatteryOptimization: false,
  );

  static const IoTPowerPolicy batterySaver = IoTPowerPolicy(
    scanInterval: Duration(minutes: 5),
    scanDuration: Duration(seconds: 5),
    reconnectAggressiveness: 0.5,
    backgroundMode: BackgroundMode.disabled,
    lowBatteryOptimization: true,
  );
}
