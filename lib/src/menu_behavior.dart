import 'dart:ui';

import 'menu.dart';
import 'placement.dart';

abstract class MenuBehavior {
  Future<void> popUp(
    Menu menu, {
    Offset? position,
    Placement placement = Placement.topLeft,
  });
}
