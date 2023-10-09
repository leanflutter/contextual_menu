import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

class _FlutterDesktopContextMenu with MenuBehavior {
  _FlutterDesktopContextMenu._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// The shared instance of [_FlutterDesktopContextMenu].
  static final _FlutterDesktopContextMenu instance =
      _FlutterDesktopContextMenu._();

  final MethodChannel _channel =
      const MethodChannel('flutter_desktop_context_menu');

  Menu? _menu;
  int? _lastHighlighted;

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onMenuItemClick':
        int id = call.arguments['id'];
        MenuItem? menuItem = _menu?.getMenuItemById(id);
        if (menuItem != null) {
          menuItem.onClick!(menuItem);
        }
        break;
      case 'onMenuItemHighlight':
        final id = call.arguments['id'] as int?;
        if (_lastHighlighted != null && _lastHighlighted != id) {
          final previouslyHighlighted =
              _menu?.getMenuItemById(_lastHighlighted!);
          previouslyHighlighted?.onLoseHighlight?.call(previouslyHighlighted);
        }
        _lastHighlighted = id;

        if (id == null) {
          break;
        }

        final menuItem = _menu?.getMenuItemById(id);
        menuItem?.onHighlight?.call(menuItem);

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
      'devicePixelRatio':
          PlatformDispatcher.instance.views.first.devicePixelRatio,
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

Future<void> popUpContextMenu(
  Menu menu, {
  Offset? position,
  Placement placement = Placement.bottomRight,
}) {
  return _FlutterDesktopContextMenu.instance.popUp(
    menu,
    position: position,
    placement: placement,
  );
}
