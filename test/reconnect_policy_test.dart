import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iot/flutter_iot.dart';

void main() {
  group('ReconnectPolicy', () {
    test('calculates exponential backoff delay', () {
      const policy = ReconnectPolicy(
        enabled: true,
        maxAttempts: 5,
        initialDelay: Duration(seconds: 1),
        backoffFactor: 2.0,
        useJitter: false,
      );

      expect(policy.shouldRetry(1), isTrue);
      expect(policy.shouldRetry(5), isTrue);
      expect(policy.shouldRetry(6), isFalse);

      final delay1 = policy.getDelayForAttempt(1);
      final delay2 = policy.getDelayForAttempt(2);
      final delay3 = policy.getDelayForAttempt(3);

      expect(delay1.inSeconds, equals(1));
      expect(delay2.inSeconds, equals(2));
      expect(delay3.inSeconds, equals(4));
    });
  });
}
