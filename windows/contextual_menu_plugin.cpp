#include "include/contextual_menu/contextual_menu_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <codecvt>
#include <map>
#include <memory>
#include <sstream>

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace {

const EncodableValue* ValueOrNull(const EncodableMap& map, const char* key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) {
    return nullptr;
  }
  return &(it->second);
}
std::unique_ptr<flutter::MethodChannel<EncodableValue>,
                std::default_delete<flutter::MethodChannel<EncodableValue>>>
    channel = nullptr;
class ContextualMenuPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  ContextualMenuPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~ContextualMenuPlugin();

 private:
  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> g_converter;

  flutter::PluginRegistrarWindows* registrar;

  // The ID of the WindowProc delegate registration.
  int window_proc_id = -1;

  HMENU hMenu;

  void ContextualMenuPlugin::_CreateMenu(HMENU menu, EncodableMap args);

  // Called for top-level WindowProc delegation.
  std::optional<LRESULT> ContextualMenuPlugin::HandleWindowProc(HWND hwnd,
                                                                UINT message,
                                                                WPARAM wparam,
                                                                LPARAM lparam);
  HWND ContextualMenuPlugin::GetMainWindow();
  void ContextualMenuPlugin::PopUp(
      const flutter::MethodCall<EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);
};

// static
void ContextualMenuPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  channel = std::make_unique<flutter::MethodChannel<EncodableValue>>(
      registrar->messenger(), "contextual_menu",
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<ContextualMenuPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

ContextualMenuPlugin::ContextualMenuPlugin(
    flutter::PluginRegistrarWindows* registrar)
    : registrar(registrar) {
  window_proc_id = registrar->RegisterTopLevelWindowProcDelegate(
      [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(hwnd, message, wparam, lparam);
      });
}

ContextualMenuPlugin::~ContextualMenuPlugin() {}

void ContextualMenuPlugin::_CreateMenu(HMENU menu, EncodableMap args) {
  EncodableList items =
      std::get<EncodableList>(args.at(EncodableValue("items")));

  int count = GetMenuItemCount(menu);
  for (int i = 0; i < count; i++) {
    // always remove at 0 because they shift every time
    RemoveMenu(menu, 0, MF_BYPOSITION);
  }

  for (EncodableValue item_value : items) {
    EncodableMap item_map = std::get<EncodableMap>(item_value);
    int id = std::get<int>(item_map.at(EncodableValue("id")));
    std::string type =
        std::get<std::string>(item_map.at(EncodableValue("type")));
    std::string label =
        std::get<std::string>(item_map.at(EncodableValue("label")));
    auto* checked = std::get_if<bool>(ValueOrNull(item_map, "checked"));
    bool disabled = std::get<bool>(item_map.at(EncodableValue("disabled")));

    UINT_PTR item_id = id;
    UINT uFlags = MF_STRING;

    if (disabled) {
      uFlags |= MF_GRAYED;
    }

    if (type.compare("separator") == 0) {
      AppendMenuW(menu, MF_SEPARATOR, item_id, NULL);
    } else {
      if (type.compare("checkbox") == 0) {
        if (checked == nullptr) {
          // skip
        } else {
          uFlags |= (*checked == true ? MF_CHECKED : MF_UNCHECKED);
        }
      } else if (type.compare("submenu") == 0) {
        uFlags |= MF_POPUP;
        HMENU sub_menu = ::CreatePopupMenu();
        _CreateMenu(sub_menu, std::get<EncodableMap>(
                                  item_map.at(EncodableValue("submenu"))));
        item_id = reinterpret_cast<UINT_PTR>(sub_menu);
      }
      AppendMenuW(menu, uFlags, item_id, g_converter.from_bytes(label).c_str());
    }
  }
}

std::optional<LRESULT> ContextualMenuPlugin::HandleWindowProc(HWND hWnd,
                                                              UINT message,
                                                              WPARAM wParam,
                                                              LPARAM lParam) {
  std::optional<LRESULT> result;
  if (message == WM_COMMAND) {
    flutter::EncodableMap eventData = flutter::EncodableMap();
    eventData[flutter::EncodableValue("id")] =
        flutter::EncodableValue((int)LOWORD(wParam));

    channel->InvokeMethod("onMenuItemClick",
                          std::make_unique<flutter::EncodableValue>(eventData));
  } else if (message == WM_MENUSELECT) {
    flutter::EncodableMap eventData = flutter::EncodableMap();
    eventData[flutter::EncodableValue("id")] =
        flutter::EncodableValue((int)LOWORD(wParam));

    channel->InvokeMethod("onMenuItemHighlight",
                          std::make_unique<flutter::EncodableValue>(eventData));
  }

  return std::nullopt;
}

HWND ContextualMenuPlugin::GetMainWindow() {
  return ::GetAncestor(registrar->GetView()->GetNativeWindow(), GA_ROOT);
}

void ContextualMenuPlugin::PopUp(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  HWND hWnd = GetMainWindow();

  const EncodableMap& args = std::get<EncodableMap>(*method_call.arguments());

  std::string placement =
      std::get<std::string>(args.at(EncodableValue("placement")));
  double device_pixel_ratio =
      std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

  hMenu = CreatePopupMenu();
  _CreateMenu(hMenu, std::get<EncodableMap>(args.at(EncodableValue("menu"))));

  double x, y;

  UINT uFlags = TPM_TOPALIGN;

  POINT cursorPos;
  GetCursorPos(&cursorPos);
  x = cursorPos.x;
  y = cursorPos.y;

  if (args.find(EncodableValue("position")) != args.end()) {
    const EncodableMap& position =
        std::get<EncodableMap>(args.at(EncodableValue("position")));

    double position_x =
        std::get<double>(position.at(flutter::EncodableValue("x")));
    double position_y =
        std::get<double>(position.at(flutter::EncodableValue("y")));

    RECT window_rect, client_rect;
    TITLEBARINFOEX title_bar_info;

    GetWindowRect(hWnd, &window_rect);
    GetClientRect(hWnd, &client_rect);
    title_bar_info.cbSize = sizeof(TITLEBARINFOEX);
    ::SendMessage(hWnd, WM_GETTITLEBARINFOEX, 0, (LPARAM)&title_bar_info);
    int32_t title_bar_height =
        title_bar_info.rcTitleBar.bottom == 0
            ? 0
            : title_bar_info.rcTitleBar.bottom - title_bar_info.rcTitleBar.top;

    int border_thickness =
        ((window_rect.right - window_rect.left) - client_rect.right) / 2;

    x = static_cast<double>((position_x * device_pixel_ratio) +
                            (window_rect.left + border_thickness));
    y = static_cast<double>((position_y * device_pixel_ratio) +
                            (window_rect.top + title_bar_height));
  }

  if (placement.compare("topLeft") == 0) {
    uFlags = TPM_BOTTOMALIGN | TPM_RIGHTALIGN;
  } else if (placement.compare("topRight") == 0) {
    uFlags = TPM_BOTTOMALIGN | TPM_LEFTALIGN;
  } else if (placement.compare("bottomLeft") == 0) {
    uFlags = TPM_TOPALIGN | TPM_RIGHTALIGN;
  } else if (placement.compare("bottomRight") == 0) {
    uFlags = TPM_TOPALIGN | TPM_LEFTALIGN;
  }

  TrackPopupMenu(hMenu, uFlags, static_cast<int>(x), static_cast<int>(y), 0,
                 hWnd, NULL);

  result->Success(EncodableValue(true));
}

void ContextualMenuPlugin::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (method_call.method_name().compare("popUp") == 0) {
    PopUp(method_call, std::move(result));
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void ContextualMenuPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ContextualMenuPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
