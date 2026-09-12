import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iot/flutter_iot.dart';

void main() {
  group('IoTLogger', () {
    test('redacts sensitive keys in log output', () async {
      final logger = IoTLogger(level: IoTLogLevel.info, enableConsole: false);

      final logFuture = logger.logs.first;

      logger.info(
        'Connecting with password=supersecret123',
        metadata: {'token': 'bearer_token_999', 'deviceId': 'dev_1'},
      );

      final record = await logFuture;
      expect(record.message, contains('***REDACTED***'));
      expect(record.metadata?['token'], equals('***REDACTED***'));
      expect(record.metadata?['deviceId'], equals('dev_1'));

      logger.dispose();
    });
  });
}
