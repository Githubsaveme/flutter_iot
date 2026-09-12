#include "include/flutter_iot/flutter_iot_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_iot_plugin.h"

void FlutterIotPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_iot::FlutterIotPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
