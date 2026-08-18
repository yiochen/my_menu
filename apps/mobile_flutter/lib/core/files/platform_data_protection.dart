import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformDataProtection {
  static const MethodChannel _channel = MethodChannel(
    'com.myaimenu.mymenu/data-protection',
  );

  static Future<void> harden() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await _channel.invokeMethod<void>('hardenLocalMenuStorage');
    }
  }
}
