import 'dart:async';
import 'package:flutter/services.dart';

class LaunchdarklyFlutter {
  static const MethodChannel _channel =
      const MethodChannel('launchdarkly_flutter');

  Future<bool> boolVariation(String flagKey, bool fallback) async {
    if(fallback == null){
      return await _channel.invokeMethod('boolVariation', flagKey);
    }else{
      return await _channel.invokeMethod('boolVariationFallback', <String, dynamic>{'flagKey': flagKey, 'fallback': fallback});
    }
  }

  Future<String> stringVariation(String flagKey, String fallback) async {
    if(fallback == null){
      return await _channel.invokeMethod('stringVariation', flagKey);
    }else{
      return await _channel.invokeMethod('stringVariationFallback', <String, dynamic>{'flagKey': flagKey, 'fallback': fallback});
    }
  }
}
