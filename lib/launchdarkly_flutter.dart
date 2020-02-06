import 'dart:async';
import 'package:flutter/services.dart';

/// Client for accessing LaunchDarkly's Feature Flag system.
/// The main entry point is the init method.
class LaunchdarklyFlutter {

  Map<String,void Function(String)> flagListeners;

  static const MethodChannel _channel =
      const MethodChannel('launchdarkly_flutter');

  LaunchdarklyFlutter() {
    flagListeners = <String,void Function(String)>{};
    _channel.setMethodCallHandler((MethodCall call) async {
      switch(call.method) {
        case 'registerFeatureFlagListener':
          _flagUpdateListener(call.arguments);
          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  /// Initializes and blocks for up to 5 seconds
  /// until the client has been initialized. If the client does not initialize within
  /// 5 seconds, it is returned anyway and can be used, but may not
  /// have fetched the most recent feature flag values.
  /// [mobileKey] is the mobile key from your Environments page in LaunchDarkly.
  /// [userKey] is the user id considered by LaunchDarkly for feature flag targeting and rollouts.
  /// The userKey should also uniquely identify each user. You can use a primary key, an e-mail address,
  /// or a hash, as long as the same user always has the same key. We recommend using a hash if possible.
  /// You can also distinguish logged-in users from anonymous users in the SDK by leaving the userKey parameter null.
  Future<bool> init(String mobileKey, String userKey) async {
    if (userKey == null) {
      return await _channel
          .invokeMethod('init', <String, dynamic>{'mobileKey': mobileKey});
    } else {
      return await _channel.invokeMethod('init',
          <String, dynamic>{'mobileKey': mobileKey, 'userKey': userKey});
    }
  }

  /// Returns the flag value for the current user. Returns 'fallback' when one of the following occurs:
  /// - Flag is missing
  /// - The flag is not of a boolean type
  /// - Any other error
  /// [flagKey] key for the flag to evaluate
  /// [fallback] fallback value in case of errors evaluating the flag
  Future<bool> boolVariation(String flagKey, bool fallback) async {
    if (fallback == null) {
      return await _channel
          .invokeMethod('boolVariation', <String, dynamic>{'flagKey': flagKey});
    } else {
      return await _channel.invokeMethod('boolVariationFallback',
          <String, dynamic>{'flagKey': flagKey, 'fallback': fallback});
    }
  }

  /// Returns the flag value for the current user. Returns 'fallback' when one of the following occurs:
  /// - Flag is missing
  /// - The flag is not of a string type
  /// - Any other error
  /// [flagKey] key for the flag to evaluate
  /// [fallback] fallback value in case of errors evaluating the flag
  Future<String> stringVariation(String flagKey, String fallback) async {
    if (fallback == null) {
      return await _channel.invokeMethod(
          'stringVariation', <String, dynamic>{'flagKey': flagKey});
    } else {
      return await _channel.invokeMethod('stringVariationFallback',
          <String, dynamic>{'flagKey': flagKey, 'fallback': fallback});
    }
  }

  Future<void> registerFeatureFlagListener(String flagKey, void Function(String) callback) async {
    flagListeners[flagKey] = callback;

    if(!flagListeners.containsKey(flagKey)){
      await _channel.invokeMethod('registerFeatureFlagListener',<String, dynamic>{'flagKey': flagKey});
    }
  }

  Future<bool> unregisterFeatureFlagListener(String flagKey) async{
    if(!flagListeners.containsKey(flagKey) || flagListeners[flagKey] == null){
      return false;
    }

    bool result = await _channel.invokeMethod('unregisterFeatureFlagListener',<String, dynamic>{'flagKey': flagKey});
    flagListeners.remove(flagKey);

    return result;
  }

  void _flagUpdateListener(Map<String,String> arguments) {
    if(arguments.containsKey('flagKey')){
      String flagKey = arguments['flagKey'];
      if(flagListeners.containsKey(flagKey)){
        Function(String) listener = flagListeners[flagKey];
        listener(flagKey);
      }
    }
  }
}
