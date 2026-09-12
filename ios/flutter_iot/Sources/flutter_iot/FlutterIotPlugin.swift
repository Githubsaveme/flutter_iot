import Flutter
import UIKit
import CoreBluetooth
import SystemConfiguration.CaptiveNetwork

public class FlutterIotPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate, CBPeripheralDelegate {
  private var channel: FlutterMethodChannel?
  private var centralManager: CBCentralManager?
  private var discoveredPeripherals: [String: CBPeripheral] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_iot", binaryMessenger: registrar.messenger())
    let instance = FlutterIotPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "checkPermission", "requestPermission":
      if let state = centralManager?.state {
        switch state {
        case .poweredOn:
          result("granted")
        case .unauthorized:
          result("denied")
        case .poweredOff, .resetting, .unknown, .unsupported:
          result("restricted")
        @unknown default:
          result("granted")
        }
      } else {
        result("granted")
      }
    case "startBleScan":
      if centralManager?.state == .poweredOn {
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        result(true)
      } else {
        result(FlutterError(code: "BLE_DISABLED", message: "Bluetooth is disabled or unauthorized", details: nil))
      }
    case "stopBleScan":
      centralManager?.stopScan()
      result(true)
    case "connectBle":
      if let args = call.arguments as? [String: Any], let deviceId = args["deviceId"] as? String, let peripheral = discoveredPeripherals[deviceId] {
        centralManager?.connect(peripheral, options: nil)
        result(true)
      } else {
        result(true)
      }
    case "disconnectBle":
      if let args = call.arguments as? [String: Any], let deviceId = args["deviceId"] as? String, let peripheral = discoveredPeripherals[deviceId] {
        centralManager?.cancelPeripheralConnection(peripheral)
      }
      result(true)
    case "getWifiInfo":
      if let ssid = fetchSSID() {
        result(["ssid": ssid])
      } else {
        result(nil)
      }
    case "startBackgroundMonitoring", "stopBackgroundMonitoring":
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func fetchSSID() -> String? {
    if let interfaces = CNCopySupportedInterfaces() as? [Array<CFString>] {
      for interface in interfaces {
        if let userInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as? [String: Any] {
          return userInfo[kCNNetworkInfoKeySSID as String] as? String
        }
      }
    }
    return nil
  }

  // CBCentralManagerDelegate
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    let stateStr: String
    switch central.state {
    case .poweredOn: stateStr = "poweredOn"
    case .poweredOff: stateStr = "poweredOff"
    case .unauthorized: stateStr = "unauthorized"
    case .unsupported: stateStr = "unsupported"
    default: stateStr = "unknown"
    }
    channel?.invokeMethod("onBluetoothStateChanged", ["state": stateStr])
  }

  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    let deviceId = peripheral.identifier.uuidString
    discoveredPeripherals[deviceId] = peripheral
    let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown BLE Device"

    channel?.invokeMethod("onBleDeviceDiscovered", [
      "id": deviceId,
      "name": name,
      "rssi": RSSI.intValue
    ])
  }
}
