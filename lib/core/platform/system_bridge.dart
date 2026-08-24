/// Platform bridge for system-level features: battery optimisation exemption.
///
/// Android side: "lifeos/system" MethodChannel in MainActivity.kt.
library;

import 'package:flutter/services.dart';

class SystemPlatformBridge {
  static const MethodChannel _channel = MethodChannel('lifeos/system');

  /// Returns true if the app is currently exempt from battery optimisation
  /// (i.e., the user has already granted the exemption).
  static Future<bool> isBatteryOptimized() async {
    try {
      return await _channel.invokeMethod<bool>('isBatteryOptimized') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Launches the system dialog that lets the user grant battery-optimisation
  /// exemption. On Android 6+ this fires ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS.
  /// On older / non-Android targets this is a no-op.
  ///
  /// Returns [true] if the exemption is now granted (verified after the dialog
  /// returns), [false] if the user declined or the channel is unavailable.
  static Future<bool> requestBatteryOptimization() async {
    try {
      return await _channel.invokeMethod<bool>('requestBatteryOptimization') ?? false;
    } on PlatformException {
      return false;
    }
  }
}
