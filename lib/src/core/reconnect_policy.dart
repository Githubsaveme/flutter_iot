import 'dart:math';

class ReconnectPolicy {
  final bool enabled;
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffFactor;
  final bool useJitter;

  const ReconnectPolicy({
    this.enabled = true,
    this.maxAttempts = 10,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 1),
    this.backoffFactor = 2.0,
    this.useJitter = true,
  });

  /// Calculate retry delay for attempt count (1-based index).
  Duration getDelayForAttempt(int attempt) {
    if (!enabled || attempt <= 0) return Duration.zero;

    final exponential = initialDelay.inMilliseconds * pow(backoffFactor, attempt - 1);
    var clampedMs = min(exponential, maxDelay.inMilliseconds.toDouble()).toDouble();

    if (useJitter) {
      final random = Random();
      final jitterFactor = 0.8 + (random.nextDouble() * 0.4); // 0.8 to 1.2
      clampedMs *= jitterFactor;
    }

    return Duration(milliseconds: clampedMs.round());
  }

  bool shouldRetry(int attempt) {
    if (!enabled) return false;
    if (maxAttempts <= 0) return true; // Infinite retries when maxAttempts <= 0
    return attempt <= maxAttempts;
  }
}
