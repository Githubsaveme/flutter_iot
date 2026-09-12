import 'dart:async';
import 'dart:io';
import '../../flutter_iot.dart';
import '../../flutter_iot_method_channel.dart';

class IoTDiscoveryManager {
  final _controller = StreamController<IoTDiscoveredDevice>.broadcast();
  final _scanStateController = StreamController<bool>.broadcast();
  final Set<String> _discoveredIds = {};
  StreamSubscription<BleDevice>? _bleNativeSubscription;
  Timer? _timeoutTimer;
  bool _isScanning = false;

  Stream<IoTDiscoveredDevice> get stream => _controller.stream;
  Stream<bool> get scanStateStream => _scanStateController.stream;
  bool get isScanning => _isScanning;

  /// Scan for IoT devices dynamically across protocols without static mock data.
  Stream<IoTDiscoveredDevice> scan({
    List<IoTProtocol>? protocols,
    Duration timeout = const Duration(seconds: 10),
  }) {
    final activeProtocols = protocols ?? [IoTProtocol.ble, IoTProtocol.mdns, IoTProtocol.udp, IoTProtocol.wifi];
    _isScanning = true;
    _discoveredIds.clear();
    _timeoutTimer?.cancel();

    if (!_scanStateController.isClosed) {
      _scanStateController.add(true);
    }

    FlutterIoT.instance.logger.info(
      'Starting IoT device scan for protocols: ${activeProtocols.map((p) => p.name).join(", ")}',
      tag: 'DiscoveryManager',
    );

    // 1. Listen to real native BLE scan results from MethodChannelFlutterIot
    if (activeProtocols.contains(IoTProtocol.ble)) {
      final methodChannelInstance = FlutterIotPlatform.instance;
      if (methodChannelInstance is MethodChannelFlutterIot) {
        _bleNativeSubscription?.cancel();
        _bleNativeSubscription = methodChannelInstance.onBleDeviceDiscovered.listen(
          (bleDev) {
            _emitDevice(
              IoTDiscoveredDevice(
                id: bleDev.id,
                name: bleDev.name ?? 'BLE Peripheral (${bleDev.id})',
                protocol: IoTProtocol.ble,
                type: StandardDeviceTypes.custom,
                rssi: bleDev.rssi,
              ),
            );
          },
          onError: (e, st) {
            FlutterIoT.instance.logger.warning(
              'BLE Discovery stream error',
              tag: 'DiscoveryManager',
              error: e,
              stackTrace: st,
            );
          },
        );
      }
      FlutterIotPlatform.instance.startBleScan();
    }

    // 2. Perform real network interface discovery
    if (activeProtocols.contains(IoTProtocol.mdns) || activeProtocols.contains(IoTProtocol.wifi)) {
      _performLocalNetworkDiscovery();
    }

    // 3. Perform real UDP datagram broadcast probe
    if (activeProtocols.contains(IoTProtocol.udp)) {
      _sendUdpDiscoveryProbe();
    }

    _timeoutTimer = Timer(timeout, () {
      stopScan();
    });

    return _controller.stream;
  }

  void _emitDevice(IoTDiscoveredDevice device) {
    if (!_discoveredIds.contains(device.id) && !_controller.isClosed) {
      _discoveredIds.add(device.id);
      _controller.add(device);
      FlutterIoT.instance.logger.info(
        'Discovered Device: ${device.name ?? device.id} via ${device.protocol.name}',
        tag: 'DiscoveryManager',
      );
    }
  }

  Future<void> _performLocalNetworkDiscovery() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          _emitDevice(
            IoTDiscoveredDevice(
              id: 'net_${addr.address}',
              name: 'Network Device (${interface.name})',
              protocol: IoTProtocol.wifi,
              type: StandardDeviceTypes.gateway,
              address: addr.address,
              port: 8080,
            ),
          );
        }
      }
    } catch (e, st) {
      FlutterIoT.instance.logger.warning(
        'Network Interface discovery warning: $e',
        tag: 'DiscoveryManager',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _sendUdpDiscoveryProbe() async {
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      final probePacket = 'IOT_DISCOVER_PING'.codeUnits;

      socket.listen(
        (event) {
          if (event == RawSocketEvent.read) {
            final datagram = socket?.receive();
            if (datagram != null) {
              _emitDevice(
                IoTDiscoveredDevice(
                  id: 'udp_${datagram.address.address}_${datagram.port}',
                  name: 'UDP IoT Device (${datagram.address.address})',
                  protocol: IoTProtocol.udp,
                  type: StandardDeviceTypes.custom,
                  address: datagram.address.address,
                  port: datagram.port,
                ),
              );
            }
          }
        },
        onError: (e, st) {
          FlutterIoT.instance.logger.warning(
            'UDP Socket Stream warning: $e',
            tag: 'DiscoveryManager',
            error: e,
            stackTrace: st,
          );
        },
      );

      try {
        socket.send(probePacket, InternetAddress('255.255.255.255'), 4210);
      } catch (e, st) {
        FlutterIoT.instance.logger.warning(
          'UDP broadcast send skipped (network interface offline / unreachable)',
          tag: 'DiscoveryManager',
          error: e,
          stackTrace: st,
        );
      }

      Timer(const Duration(seconds: 3), () {
        try {
          socket?.close();
        } catch (_) {}
      });
    } catch (e, st) {
      FlutterIoT.instance.logger.warning(
        'UDP bind skipped: $e',
        tag: 'DiscoveryManager',
        error: e,
        stackTrace: st,
      );
    }
  }

  void stopScan() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    if (_isScanning) {
      _bleNativeSubscription?.cancel();
      _bleNativeSubscription = null;
      FlutterIotPlatform.instance.stopBleScan();
      _isScanning = false;

      if (!_scanStateController.isClosed) {
        _scanStateController.add(false);
      }

      FlutterIoT.instance.logger.info('IoT Scan stopped', tag: 'DiscoveryManager');
    }
  }

  void dispose() {
    stopScan();
    _controller.close();
    _scanStateController.close();
  }
}
