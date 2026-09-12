import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot/flutter_iot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterIoT.instance.initialize(
    const IoTConfig(
      enableLogging: true,
      logLevel: IoTLogLevel.debug,
      autoReconnect: true,
    ),
  );
  runApp(const FlutterIoTExampleApp());
}

class FlutterIoTExampleApp extends StatelessWidget {
  const FlutterIoTExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter IoT SDK Control Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardTab(),
    BleScannerTab(),
    WifiDiscoveryTab(),
    MqttWebSocketTab(),
    HttpRestTab(),
    DiagnosticsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter IoT Control Center'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.bluetooth_searching), selectedIcon: Icon(Icons.bluetooth), label: 'BLE'),
          NavigationDestination(icon: Icon(Icons.wifi_find), selectedIcon: Icon(Icons.wifi), label: 'Wi-Fi'),
          NavigationDestination(icon: Icon(Icons.cloud_sync_outlined), selectedIcon: Icon(Icons.cloud_sync), label: 'MQTT/WS'),
          NavigationDestination(icon: Icon(Icons.http), selectedIcon: Icon(Icons.http_sharp), label: 'HTTP'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'System'),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _iot = FlutterIoT.instance;
  final List<IoTDiscoveredDevice> _discovered = [];
  StreamSubscription? _subscription;
  StreamSubscription<bool>? _scanStateSub;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanStateSub = _iot.discovery.scanStateStream.listen((isScanning) {
      if (!mounted) return;
      setState(() {
        _isScanning = isScanning;
      });
    });
    _startScan();
  }

  void _startScan() async {
    await _iot.permissions.ensureBlePermissions();
    _subscription?.cancel();
    if (!mounted) return;
    setState(() {
      _discovered.clear();
    });

    _subscription = _iot.scan().listen((device) {
      if (!mounted) return;
      setState(() {
        if (!_discovered.any((d) => d.id == device.id)) {
          _discovered.add(device);
        }
      });
    });
  }

  @override
  void dispose() {
    _scanStateSub?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Discovered Devices', '${_discovered.length}', Icons.devices, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard('Platform', _iot.capabilities.platform, Icons.phone_android, Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Bluetooth', _iot.capabilities.bluetooth ? 'Available' : 'Disabled', Icons.bluetooth, Colors.blueAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard('Background Monitor', _iot.monitoring.isMonitoring ? 'Active' : 'Idle', Icons.notifications_active, Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Discovered IoT Devices', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
                onPressed: _isScanning ? () => _iot.discovery.stopScan() : _startScan,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_discovered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(_isScanning ? 'Scanning for active nearby IoT devices...' : 'Scan complete. Tap play to scan again.'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _discovered.length,
              itemBuilder: (context, idx) {
                final dev = _discovered[idx];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_getProtocolIcon(dev.protocol)),
                    ),
                    title: Text(dev.name ?? dev.id),
                    subtitle: Text('ID: ${dev.id} • Protocol: ${dev.protocol.name.toUpperCase()}'),
                    trailing: Chip(
                      label: Text(dev.rssi != null ? '${dev.rssi} dBm' : 'Detected'),
                      backgroundColor: Colors.blue.withAlpha(50),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  IconData _getProtocolIcon(IoTProtocol protocol) {
    switch (protocol) {
      case IoTProtocol.ble:
        return Icons.bluetooth;
      case IoTProtocol.wifi:
      case IoTProtocol.mdns:
        return Icons.wifi;
      case IoTProtocol.mqtt:
        return Icons.cloud;
      case IoTProtocol.webSocket:
        return Icons.sync;
      case IoTProtocol.http:
        return Icons.http;
      case IoTProtocol.tcp:
        return Icons.lan;
      case IoTProtocol.udp:
        return Icons.cell_tower;
    }
  }
}

class BleScannerTab extends StatefulWidget {
  const BleScannerTab({super.key});

  @override
  State<BleScannerTab> createState() => _BleScannerTabState();
}

class _BleScannerTabState extends State<BleScannerTab> {
  bool _isScanning = false;
  final List<IoTDiscoveredDevice> _bleDevices = [];
  StreamSubscription? _bleScanSubscription;
  StreamSubscription<bool>? _scanStateSub;

  @override
  void initState() {
    super.initState();
    _scanStateSub = FlutterIoT.instance.discovery.scanStateStream.listen((isScanning) {
      if (!mounted) return;
      setState(() {
        _isScanning = isScanning;
      });
    });
  }

  Future<void> _toggleBleScan() async {
    if (!_isScanning) {
      final granted = await FlutterIoT.instance.permissions.ensureBlePermissions();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth permissions required for native BLE scan')),
        );
      }
      setState(() {
        _bleDevices.clear();
      });

      _bleScanSubscription = FlutterIoT.instance.scan(protocols: [IoTProtocol.ble]).listen((device) {
        if (!mounted) return;
        setState(() {
          if (!_bleDevices.any((d) => d.id == device.id)) {
            _bleDevices.add(device);
          }
        });
      });
    } else {
      _bleScanSubscription?.cancel();
      FlutterIoT.instance.discovery.stopScan();
    }
  }

  Future<void> _connectToDevice(IoTDiscoveredDevice device) async {
    final bleTransport = FlutterIoT.instance.ble(deviceId: device.id);
    try {
      await bleTransport.connect();
      final services = await bleTransport.discoverServices();
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connected to ${device.name ?? device.id}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('GATT Services Found (${services.length}):'),
              const SizedBox(height: 8),
              ...services.map((s) => Text('• $s', style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await bleTransport.disconnect();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Disconnect Device'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('BLE Connection error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _scanStateSub?.cancel();
    _bleScanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BLE Central Manager', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: Icon(_isScanning ? Icons.stop : Icons.search),
                label: Text(_isScanning ? 'Stop' : 'Scan BLE'),
                onPressed: _toggleBleScan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _bleDevices.isEmpty
                ? Center(
                    child: Text(_isScanning ? 'Scanning for nearby Bluetooth LE peripherals...' : 'Tap "Scan BLE" to start scanning'),
                  )
                : ListView.builder(
                    itemCount: _bleDevices.length,
                    itemBuilder: (context, idx) {
                      final dev = _bleDevices[idx];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.bluetooth),
                          ),
                          title: Text(dev.name ?? dev.id),
                          subtitle: Text('ID: ${dev.id}'),
                          trailing: ElevatedButton(
                            onPressed: () => _connectToDevice(dev),
                            child: const Text('Connect'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class WifiDiscoveryTab extends StatefulWidget {
  const WifiDiscoveryTab({super.key});

  @override
  State<WifiDiscoveryTab> createState() => _WifiDiscoveryTabState();
}

class _WifiDiscoveryTabState extends State<WifiDiscoveryTab> {
  Map<String, dynamic>? _wifiInfo;
  List<NetworkDevice> _netDevices = [];

  @override
  void initState() {
    super.initState();
    _loadWifiInfo();
  }

  Future<void> _loadWifiInfo() async {
    await FlutterIoT.instance.permissions.ensureWifiPermissions();
    final info = await FlutterIoT.instance.wifi.getWifiInfo();
    final discoveredNet = await FlutterIoT.instance.wifi.discover();
    if (!mounted) return;
    setState(() {
      _wifiInfo = info;
      _netDevices = discoveredNet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Local Network & Wi-Fi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadWifiInfo),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.wifi, size: 36, color: Colors.blue),
              title: Text('SSID: ${_wifiInfo?["ssid"] ?? "Disconnected / Unavailable"}'),
              subtitle: Text('IP Address: ${_wifiInfo?["ip"] ?? "0.0.0.0"}\nBSSID: ${_wifiInfo?["bssid"] ?? "N/A"}'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Local Interface Devices (${_netDevices.length})', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _netDevices.length,
              itemBuilder: (context, idx) {
                final netDev = _netDevices[idx];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.router),
                    title: Text(netDev.name ?? netDev.id),
                    subtitle: Text('Address: ${netDev.address.address}:${netDev.port ?? 80}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MqttWebSocketTab extends StatefulWidget {
  const MqttWebSocketTab({super.key});

  @override
  State<MqttWebSocketTab> createState() => _MqttWebSocketTabState();
}

class _MqttWebSocketTabState extends State<MqttWebSocketTab> {
  final _messages = <String>[];
  final _hostController = TextEditingController(text: 'broker.hivemq.com');
  final _topicController = TextEditingController(text: 'flutter_iot/demo');
  final _payloadController = TextEditingController(text: '{"temperature": 24.5}');
  MqttTransport? _mqttTransport;
  bool _isConnected = false;

  Future<void> _connectMqtt() async {
    final config = MqttConfig(
      host: _hostController.text.trim(),
      port: 1883,
      clientId: 'flutter_iot_${DateTime.now().millisecondsSinceEpoch}',
    );

    _mqttTransport = FlutterIoT.instance.mqtt(config);
    try {
      await _mqttTransport!.connect();
      await _mqttTransport!.subscribe(_topicController.text.trim());
      
      _mqttTransport!.messages.listen((msg) {
        if (!mounted) return;
        setState(() {
          _messages.add('[IN] Topic: ${msg.topic} -> Payload: ${msg.payload}');
        });
      });

      setState(() {
        _isConnected = true;
        _messages.add('[SYS] Connected to ${_hostController.text} and subscribed to ${_topicController.text}');
      });
    } catch (e) {
      setState(() {
        _messages.add('[ERR] Connection failed: $e');
      });
    }
  }

  Future<void> _publishMqtt() async {
    if (_mqttTransport == null || !_isConnected) return;
    final topic = _topicController.text.trim();
    final payload = _payloadController.text.trim();

    await _mqttTransport!.publish(topic: topic, payload: payload);
    setState(() {
      _messages.add('[OUT] Topic: $topic -> Payload: $payload');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hostController,
                  decoration: const InputDecoration(labelText: 'MQTT Host', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isConnected ? null : _connectMqtt,
                child: Text(_isConnected ? 'Connected' : 'Connect'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(labelText: 'Topic', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _payloadController,
                  decoration: const InputDecoration(labelText: 'Payload', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.send),
                onPressed: _publishMqtt,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, idx) => Text(_messages[idx], style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HttpRestTab extends StatefulWidget {
  const HttpRestTab({super.key});

  @override
  State<HttpRestTab> createState() => _HttpRestTabState();
}

class _HttpRestTabState extends State<HttpRestTab> {
  final _urlController = TextEditingController(text: 'https://httpbin.org/get');
  String _responseOutput = 'Tap GET or POST Request to execute live HTTP network call';
  bool _isLoading = false;

  Future<void> _executeHttpGet() async {
    setState(() {
      _isLoading = true;
      _responseOutput = 'Executing HTTP GET request...';
    });

    final http = FlutterIoT.instance.http('');
    try {
      final res = await http.get(_urlController.text.trim());
      setState(() {
        _isLoading = false;
        _responseOutput = 'Status Code: ${res.statusCode}\n\nResponse Body:\n${res.body}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseOutput = 'HTTP Request Error: $e';
      });
    }
  }

  Future<void> _executeHttpPost() async {
    setState(() {
      _isLoading = true;
      _responseOutput = 'Executing HTTP POST request...';
    });

    final http = FlutterIoT.instance.http('');
    try {
      final res = await http.post(
        'https://httpbin.org/post',
        body: {'client': 'flutter_iot', 'timestamp': DateTime.now().toIso8601String()},
      );
      setState(() {
        _isLoading = false;
        _responseOutput = 'Status Code: ${res.statusCode}\n\nResponse Body:\n${res.body}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseOutput = 'HTTP Request Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'HTTP Endpoint URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('GET Request'),
                  onPressed: _isLoading ? null : _executeHttpGet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('POST Request'),
                  onPressed: _isLoading ? null : _executeHttpPost,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _responseOutput,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagnosticsTab extends StatefulWidget {
  const DiagnosticsTab({super.key});

  @override
  State<DiagnosticsTab> createState() => _DiagnosticsTabState();
}

class _DiagnosticsTabState extends State<DiagnosticsTab> {
  final _iot = FlutterIoT.instance;
  Map<IoTPermission, IoTPermissionStatus> _permStatus = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await _iot.permissions.checkAll([
      IoTPermission.bluetoothScan,
      IoTPermission.bluetoothConnect,
      IoTPermission.location,
      IoTPermission.nearbyWifiDevices,
      IoTPermission.localNetwork,
    ]);
    if (!mounted) return;
    setState(() {
      _permStatus = status;
    });
  }

  Future<void> _requestPerm(IoTPermission perm) async {
    await _iot.permissions.request(perm);
    _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final caps = _iot.capabilities;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Capabilities Matrix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildCapTile('Bluetooth LE Central', caps.bluetooth),
        _buildCapTile('Wi-Fi & mDNS', caps.wifi),
        _buildCapTile('MQTT Transport', caps.mqtt),
        _buildCapTile('WebSocket Transport', caps.webSocket),
        _buildCapTile('HTTP / REST', caps.http),
        _buildCapTile('TCP Sockets', caps.tcp),
        _buildCapTile('UDP Datagrams', caps.udp),
        _buildCapTile('Background Monitoring', caps.backgroundMonitoring),
        const SizedBox(height: 24),
        const Text('Feature Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._permStatus.entries.map((entry) {
          final isGranted = entry.value == IoTPermissionStatus.granted;
          return Card(
            child: ListTile(
              title: Text(entry.key.name.toUpperCase()),
              subtitle: Text('Status: ${entry.value.name}'),
              trailing: ElevatedButton(
                onPressed: () => _requestPerm(entry.key),
                child: Text(isGranted ? 'Granted' : 'Request'),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCapTile(String title, bool supported) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Icon(
          supported ? Icons.check_circle : Icons.cancel,
          color: supported ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
