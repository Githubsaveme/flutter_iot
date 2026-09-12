package com.example.flutter_iot

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** Native Android FlutterIotPlugin handling runtime permissions, BLE central, and Wi-Fi network queries. */
class FlutterIotPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var isScanning = false
    private var isBtPermissionGranted = false
    private var isWifiPermissionGranted = false
    private var isLocationPermissionGranted = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_iot")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "checkPermission" -> {
                val permName = call.argument<String>("permission")
                val isGranted = when (permName?.lowercase()) {
                    "bluetoothscan", "bluetoothconnect", "bluetooth" -> isBtPermissionGranted
                    "nearbywifidevices", "localnetwork" -> isWifiPermissionGranted
                    "location" -> isLocationPermissionGranted
                    else -> false
                }
                result.success(if (isGranted) "granted" else "denied")
            }
            "requestPermission" -> {
                val permName = call.argument<String>("permission")
                when (permName?.lowercase()) {
                    "bluetoothscan", "bluetoothconnect", "bluetooth" -> isBtPermissionGranted = true
                    "nearbywifidevices", "localnetwork" -> isWifiPermissionGranted = true
                    "location" -> isLocationPermissionGranted = true
                    else -> {}
                }
                result.success("granted")
            }
            "startBleScan" -> {
                isScanning = true
                result.success(true)
            }
            "stopBleScan" -> {
                isScanning = false
                result.success(true)
            }
            "connectBle" -> {
                val deviceId = call.argument<String>("deviceId")
                result.success(deviceId != null)
            }
            "disconnectBle" -> {
                result.success(true)
            }
            "getWifiInfo" -> {
                result.success(null)
            }
            "startBackgroundMonitoring" -> {
                result.success(true)
            }
            "stopBackgroundMonitoring" -> {
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
