#ifndef FLUTTER_PLUGIN_FLUTTER_IOT_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_IOT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_iot {

class FlutterIotPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterIotPlugin();

  virtual ~FlutterIotPlugin();

  // Disallow copy and assign.
  FlutterIotPlugin(const FlutterIotPlugin&) = delete;
  FlutterIotPlugin& operator=(const FlutterIotPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_iot

#endif  // FLUTTER_PLUGIN_FLUTTER_IOT_PLUGIN_H_
