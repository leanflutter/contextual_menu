import 'menu_item.dart';

class Menu {
  List<MenuItem>? items;

  Menu({
    this.items,
  });

  MenuItem? getMenuItem(String key) {
    for (MenuItem menuItem in (items ?? [])) {
      if (menuItem.key == key) {
        return menuItem;
      }
      if (menuItem.submenu?.getMenuItem(key) != null) {
        return menuItem.submenu?.getMenuItem(key);
      }
    }
    return null;
  }

  MenuItem? getMenuItemById(int id) {
    for (MenuItem menuItem in (items ?? [])) {
      if (menuItem.id == id) {
        return menuItem;
      }
      if (menuItem.submenu?.getMenuItemById(id) != null) {
        return menuItem.submenu?.getMenuItemById(id);
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}
