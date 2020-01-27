import 'dart:async';
import 'package:flutter/services.dart';

class LaunchdarklyFlutter {
  static const MethodChannel _channel =
      const MethodChannel('launchdarkly_flutter');

  Future<bool> init(String mobileKey, String userKey, String userEmail) async {
    if(userKey == null || userEmail == null){
      return await _channel.invokeMethod('init', <String, dynamic>{'mobileKey': mobileKey});
    }else {
      return await _channel.invokeMethod('init', <String, dynamic>{'mobileKey': mobileKey, 'userKey': userKey,'userEmail': userEmail});
    }
  }

  Future<bool> boolVariation(String flagKey, bool fallback) async {
    if(fallback == null){
      return await _channel.invokeMethod('boolVariation', <String, dynamic>{'flagKey': flagKey});
    }else{
      return await _channel.invokeMethod('boolVariationFallback', <String, dynamic>{'flagKey': flagKey, 'fallback': fallback});
    }
  }

  Future<String> stringVariation(String flagKey, String fallback) async {
    if(fallback == null){
      return await _channel.invokeMethod('stringVariation', <String, dynamic>{'flagKey': flagKey});
    }else{
      return await _channel.invokeMethod('stringVariationFallback', <String, dynamic>{'flagKey': flagKey, 'fallback': fallback});
    }
  }
}
