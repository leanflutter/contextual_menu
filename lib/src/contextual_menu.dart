import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:menu_base/menu_base.dart';

class _ContextualMenu with MenuBehavior {
  _ContextualMenu._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// The shared instance of [_ContextualMenu].
  static final _ContextualMenu instance = _ContextualMenu._();

  final MethodChannel _channel = const MethodChannel('contextual_menu');

  Menu? _menu;

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onMenuItemClick':
        int id = call.arguments['id'];
        MenuItem? menuItem = _menu?.getMenuItemById(id);
        if (menuItem != null) {
          menuItem.onClick!(menuItem);
        }
        break;
    }
  }

  @override
  Future<void> popUp(
    Menu menu, {
    Offset? position,
    Placement placement = Placement.topLeft,
  }) async {
    _menu = menu;
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'menu': menu.toJson(),
      'position': position != null
          ? {
              'x': position.dx,
              'y': position.dy,
            }
          : null,
      'placement': describeEnum(placement),
    }..removeWhere((key, value) => value == null);
    await _channel.invokeMethod('popUp', arguments);
  }
}

Future<void> popUpContextualMenu(
  Menu menu, {
  Offset? position,
  Placement placement = Placement.bottomRight,
}) {
  return _ContextualMenu.instance.popUp(
    menu,
    position: position,
    placement: placement,
  );
}
