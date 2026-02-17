import 'package:flutter/services.dart';

class OverlayWindow {
  static const _channel = MethodChannel('overlay/window');

  static Future<void> setTopmost(bool enabled) async {
    await _channel.invokeMethod('setTopmost', enabled);
  }

  static Future<void> forceToTop() async {
    await _channel.invokeMethod('forceToTop');
  }
}