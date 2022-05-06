
import 'dart:async';

import 'package:flutter/services.dart';

class ContextualMenu {
  static const MethodChannel _channel = MethodChannel('contextual_menu');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
