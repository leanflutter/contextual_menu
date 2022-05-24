#include "include/contextual_menu/contextual_menu_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <algorithm>
#include <cstring>
#include <map>

#define CONTEXTUAL_MENU_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), contextual_menu_plugin_get_type(), \
                              ContextualMenuPlugin))

ContextualMenuPlugin* plugin_instance;

GtkWidget* menu = nullptr;

struct _ContextualMenuPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
};

G_DEFINE_TYPE(ContextualMenuPlugin, contextual_menu_plugin, g_object_get_type())

// Gets the window being controlled.
GtkWindow* get_window(ContextualMenuPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr)
    return nullptr;

  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

GdkWindow* get_gdk_window(ContextualMenuPlugin* self) {
  return gtk_widget_get_window(GTK_WIDGET(get_window(self)));
}

void _on_activate(GtkMenuItem* item, gpointer user_data) {
  gint id = GPOINTER_TO_INT(user_data);

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "id", fl_value_new_int(id));
  fl_method_channel_invoke_method(plugin_instance->channel, "onMenuItemClick",
                                  result_data, nullptr, nullptr, nullptr);
}

void _on_select(GtkMenuItem* item, gpointer user_data) {
  gint id = GPOINTER_TO_INT(user_data);

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "id", fl_value_new_int(id));
  fl_method_channel_invoke_method(plugin_instance->channel,
                                  "onMenuItemHighlight", result_data, nullptr,
                                  nullptr, nullptr);
}

void _on_deselect(GtkMenuItem* item, gpointer user_data) {
  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "id", fl_value_new_null());
  fl_method_channel_invoke_method(plugin_instance->channel,
                                  "onMenuItemHighlight", result_data, nullptr,
                                  nullptr, nullptr);
}

GtkWidget* _create_menu(FlValue* args) {
  FlValue* items_value = fl_value_lookup_string(args, "items");

  GtkWidget* menu = gtk_menu_new();
  for (gint i = 0; i < fl_value_get_length(items_value); i++) {
    FlValue* item_value = fl_value_get_list_value(items_value, i);
    const int id = fl_value_get_int(fl_value_lookup_string(item_value, "id"));
    const char* type =
        fl_value_get_string(fl_value_lookup_string(item_value, "type"));
    const char* label =
        fl_value_get_string(fl_value_lookup_string(item_value, "label"));
    const bool disabled =
        fl_value_get_bool(fl_value_lookup_string(item_value, "disabled"));

    gint item_id = id;

    if (strcmp(type, "separator") == 0) {
      gtk_menu_shell_append(GTK_MENU_SHELL(menu),
                            gtk_separator_menu_item_new());
    } else {
      GtkWidget* item = gtk_menu_item_new_with_label(label);

      if (disabled) {
        gtk_widget_set_sensitive(item, FALSE);
      }

      if (strcmp(type, "checkbox") == 0) {
        item = gtk_check_menu_item_new_with_label(label);
        const auto checked_value =
            fl_value_lookup_string(item_value, "checked");
        if (checked_value != nullptr) {
          const auto checked = fl_value_get_bool(checked_value);
          gtk_check_menu_item_set_active((GtkCheckMenuItem*)item, checked);
        }
      } else if (strcmp(type, "submenu") == 0) {
        GtkWidget* sub_menu =
            _create_menu(fl_value_lookup_string(item_value, "submenu"));
        gtk_menu_item_set_submenu(GTK_MENU_ITEM(item), sub_menu);
      }

      g_signal_connect(G_OBJECT(item), "activate", G_CALLBACK(_on_activate),
                       GINT_TO_POINTER(item_id));
      g_signal_connect(G_OBJECT(item), "select", G_CALLBACK(_on_select),
                       GINT_TO_POINTER(item_id));
      g_signal_connect(G_OBJECT(item), "deselect", G_CALLBACK(_on_deselect),
                       GINT_TO_POINTER(item_id));

      gtk_menu_shell_append(GTK_MENU_SHELL(menu), item);
    }
  }
  return menu;
}

static FlMethodResponse* pop_up(ContextualMenuPlugin* self, FlValue* args) {
  menu = _create_menu(fl_value_lookup_string(args, "menu"));
  auto device_pixel_ratio = fl_value_lookup_string(args, "devicePixelRatio");
  auto position = fl_value_lookup_string(args, "position");
  const char* placement =
      fl_value_get_string(fl_value_lookup_string(args, "placement"));

  gtk_widget_show_all(menu);

  GdkWindow* gdk_window = get_gdk_window(self);

  GdkRectangle rectangle;

  if (device_pixel_ratio != nullptr && position != nullptr) {
    GdkRectangle frame_rectangle;
    gdk_window_get_frame_extents(gdk_window, &frame_rectangle);

    gint window_x, window_y;
    gtk_window_get_position(get_window(self), &window_x, &window_y);

    int title_bar_height = gtk_widget_get_allocated_height(
        gtk_window_get_titlebar(get_window(self)));

    rectangle.x = (fl_value_get_float(fl_value_lookup_string(position, "x")) *
                   fl_value_get_float(device_pixel_ratio)) +
                  window_x - frame_rectangle.x;
    rectangle.y = (fl_value_get_float(fl_value_lookup_string(position, "y")) *
                   fl_value_get_float(device_pixel_ratio)) +
                  window_y - frame_rectangle.y + title_bar_height;
  } else {
    GdkDevice* mouse_device;
    int x, y;
    // Legacy support.
#if GTK_CHECK_VERSION(3, 20, 0)
    GdkSeat* seat = gdk_display_get_default_seat(gdk_display_get_default());
    mouse_device = gdk_seat_get_pointer(seat);
#else
    GdkDeviceManager* devman =
        gdk_display_get_device_manager(gdk_display_get_default());
    mouse_device = gdk_device_manager_get_client_pointer(devman);
#endif
    gdk_window_get_device_position(gdk_window, mouse_device, &x, &y, NULL);
    rectangle.x = x;
    rectangle.y = y;
  }

  GdkGravity menu_anchor = GDK_GRAVITY_NORTH_WEST;

  if (strcmp(placement, "topLeft") == 0) {
    menu_anchor = GDK_GRAVITY_SOUTH_EAST;
  } else if (strcmp(placement, "topRight") == 0) {
    menu_anchor = GDK_GRAVITY_SOUTH_WEST;
  } else if (strcmp(placement, "bottomLeft") == 0) {
    menu_anchor = GDK_GRAVITY_NORTH_EAST;
  } else if (strcmp(placement, "bottomRight") == 0) {
    menu_anchor = GDK_GRAVITY_NORTH_WEST;
  }

  gtk_menu_popup_at_rect(GTK_MENU(menu), gdk_window, &rectangle,
                         GDK_GRAVITY_NORTH_WEST, menu_anchor, NULL);

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

// Called when a method call is received from Flutter.
static void contextual_menu_plugin_handle_method_call(
    ContextualMenuPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "popUp") == 0) {
    response = pop_up(self, args);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void contextual_menu_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(contextual_menu_plugin_parent_class)->dispose(object);
}

static void contextual_menu_plugin_class_init(
    ContextualMenuPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = contextual_menu_plugin_dispose;
}

static void contextual_menu_plugin_init(ContextualMenuPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  ContextualMenuPlugin* plugin = CONTEXTUAL_MENU_PLUGIN(user_data);
  contextual_menu_plugin_handle_method_call(plugin, method_call);
}

void contextual_menu_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  ContextualMenuPlugin* plugin = CONTEXTUAL_MENU_PLUGIN(
      g_object_new(contextual_menu_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "contextual_menu", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  plugin_instance = plugin;

  g_object_unref(plugin);
}
