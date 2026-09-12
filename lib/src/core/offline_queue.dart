import 'dart:collection';
import '../models/iot_command.dart';
import '../models/iot_message.dart';

class OfflineQueue {
  final int maxCapacity;
  final Queue<dynamic> _queue = Queue<dynamic>();

  OfflineQueue({this.maxCapacity = 100});

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  void enqueue(dynamic item) {
    if (item is! IoTCommand && item is! IoTMessage) {
      throw ArgumentError('OfflineQueue only accepts IoTCommand or IoTMessage');
    }

    if (_queue.length >= maxCapacity) {
      _queue.removeFirst(); // Drop oldest element when full
    }
    _queue.addLast(item);
  }

  dynamic dequeue() {
    if (_queue.isEmpty) return null;
    return _queue.removeFirst();
  }

  List<dynamic> drain() {
    final items = _queue.toList();
    _queue.clear();
    return items;
  }

  void clear() {
    _queue.clear();
  }
}
