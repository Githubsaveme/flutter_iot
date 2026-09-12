import '../../flutter_iot_platform_interface.dart';

enum IoTPermission {
  bluetooth,
  bluetoothScan,
  bluetoothConnect,
  bluetoothAdvertise,
  location,
  nearbyWifiDevices,
  localNetwork,
}

enum IoTPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unknown,
}

class IoTPermissionsManager {
  IoTPermissionsManager();

  /// Check the status of a specific IoT permission.
  Future<IoTPermissionStatus> check(IoTPermission permission) async {
    final statusStr = await FlutterIotPlatform.instance.checkPermission(permission.name);
    return _parseStatus(statusStr);
  }

  /// Request a specific IoT permission from the OS.
  Future<IoTPermissionStatus> request(IoTPermission permission) async {
    final statusStr = await FlutterIotPlatform.instance.requestPermission(permission.name);
    return _parseStatus(statusStr);
  }

  /// Check multiple IoT permissions at once.
  Future<Map<IoTPermission, IoTPermissionStatus>> checkAll(List<IoTPermission> permissions) async {
    final results = <IoTPermission, IoTPermissionStatus>{};
    for (final perm in permissions) {
      results[perm] = await check(perm);
    }
    return results;
  }

  /// Request multiple IoT permissions at once.
  Future<Map<IoTPermission, IoTPermissionStatus>> requestAll(List<IoTPermission> permissions) async {
    final results = <IoTPermission, IoTPermissionStatus>{};
    for (final perm in permissions) {
      results[perm] = await request(perm);
    }
    return results;
  }

  /// Ensure BLE scanning & connection permissions are requested and granted.
  Future<bool> ensureBlePermissions() async {
    final status = await requestAll([
      IoTPermission.bluetoothScan,
      IoTPermission.bluetoothConnect,
      IoTPermission.bluetooth,
    ]);
    return status.values.every((s) => s == IoTPermissionStatus.granted);
  }

  /// Ensure Wi-Fi & local network permissions are requested and granted.
  Future<bool> ensureWifiPermissions() async {
    final status = await requestAll([
      IoTPermission.nearbyWifiDevices,
      IoTPermission.location,
      IoTPermission.localNetwork,
    ]);
    return status.values.any((s) => s == IoTPermissionStatus.granted);
  }

  /// Check if all Bluetooth permissions required for scanning and connecting are granted.
  Future<bool> hasBluetoothPermissions() async {
    final scan = await check(IoTPermission.bluetoothScan);
    final connect = await check(IoTPermission.bluetoothConnect);
    final bt = await check(IoTPermission.bluetooth);
    return scan == IoTPermissionStatus.granted &&
        connect == IoTPermissionStatus.granted &&
        bt == IoTPermissionStatus.granted;
  }

  /// Check if Wi-Fi and location permissions are granted.
  Future<bool> hasWifiPermissions() async {
    final wifi = await check(IoTPermission.nearbyWifiDevices);
    final loc = await check(IoTPermission.location);
    return wifi == IoTPermissionStatus.granted || loc == IoTPermissionStatus.granted;
  }

  IoTPermissionStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'granted':
        return IoTPermissionStatus.granted;
      case 'denied':
        return IoTPermissionStatus.denied;
      case 'permanentlydenied':
        return IoTPermissionStatus.permanentlyDenied;
      case 'restricted':
        return IoTPermissionStatus.restricted;
      default:
        return IoTPermissionStatus.unknown;
    }
  }
}
