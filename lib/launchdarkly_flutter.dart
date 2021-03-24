import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Client for accessing LaunchDarkly's Feature Flag system.
class LaunchdarklyFlutter {
  Map<String, void Function(String?)>? flagListeners;
  Map<String, void Function(List<String>)>? allFlagsListeners;
  static const MethodChannel _channel =
      const MethodChannel('launchdarkly_flutter');

  /// Constructor for the Client for accessing LaunchDarkly's Feature Flag system.
  /// The main entry point.
  /// [flagListeners] (optional) is the map of flag keys and callbacks.
  LaunchdarklyFlutter({this.flagListeners, this.allFlagsListeners}) {
    flagListeners ??= {};
    allFlagsListeners ??= {};

    _channel.setMethodCallHandler(handlerMethodCalls);
  }

  @visibleForTesting
  Future<dynamic> handlerMethodCalls(MethodCall call) async {
    switch (call.method) {
      case 'callbackRegisterFeatureFlagListener':
        if (call.arguments == null) {
          return false;
        }

        if (!call.arguments.containsKey('flagKey')) {
          return false;
        }

        String? flagKey = call.arguments['flagKey'];

        if (!flagListeners!.containsKey(flagKey)) {
          return false;
        }

        Function(String?)? listener = flagListeners![flagKey!];
        if (listener != null) listener(flagKey);
        return true;

      case 'callbackAllFlagsListener':
        if (call.arguments == null) {
          return false;
        }

        if (!call.arguments.containsKey('flagKeys')) {
          return false;
        }

        List<String> flagKeys = List<String>.from(call.arguments['flagKeys']);

        if (allFlagsListeners!.isEmpty) {
          return false;
        }

        allFlagsListeners!.values.forEach((allFlagsListener) {
          allFlagsListener(flagKeys);
        });

        return true;
      default:
        throw MissingPluginException();
    }
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
  /// You can pass custom arguments in [custom] map.
  Future<bool?> init(
    String? mobileKey,
    String? userKey, {
    Map<String, dynamic>? custom,
  }) async {
    if (userKey == null) {
      return await _channel.invokeMethod('init', <String, dynamic>{
        'mobileKey': mobileKey,
        'custom': custom,
      });
    } else {
      return await _channel.invokeMethod('init', <String, dynamic>{
        'mobileKey': mobileKey,
        'userKey': userKey,
        'custom': custom,
      });
    }
  }

  /// Changes user context.
  ///
  /// If your app is used by multiple users on a single device, you may want
  /// to change users and have separate flag settings for each user.
  /// Use this method to switch user contexts.
  ///
  /// [userKey] is the user id considered by LaunchDarkly for feature flag
  /// targeting and rollouts (see [init]).
  ///
  /// You can pass custom arguments in [custom] map.
  Future<bool?> identify(String? userKey, {Map<String, dynamic>? custom}) =>
      _channel.invokeMethod('identify', <String, dynamic>{
        'userKey': userKey,
        'custom': custom,
      });

  /// Returns the flag value for the current user. Returns 'fallback' when one of the following occurs:
  /// - Flag is missing
  /// - The flag is not of a boolean type
  /// - Any other error
  /// [flagKey] key for the flag to evaluate
  /// [fallback] fallback value in case of errors evaluating the flag
  Future<bool?> boolVariation(String flagKey, bool? fallback) async {
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
  Future<String?> stringVariation(String flagKey, String? fallback) async {
    if (fallback == null) {
      return await _channel.invokeMethod(
          'stringVariation', <String, dynamic>{'flagKey': flagKey});
    } else {
      return await _channel.invokeMethod('stringVariationFallback',
          <String, dynamic>{'flagKey': flagKey, 'fallback': fallback});
    }
  }

  /// Registers a callback to be called when the flagKey changes
  /// from its current value. If the feature flag is deleted, the listener will be unregistered.
  ///
  /// [flagKey]  the flag key to attach the listener to
  /// [callback] the listener to attach to the flag key
  Future<bool?> registerFeatureFlagListener(
      String? flagKey, void Function(String?)? callback) async {
    if (flagKey == null || callback == null) {
      return false;
    }

    if (flagListeners!.containsKey(flagKey)) {
      flagListeners![flagKey] = callback;
      return true;
    }

    flagListeners![flagKey] = callback;
    return await _channel.invokeMethod(
        'registerFeatureFlagListener', <String, dynamic>{'flagKey': flagKey});
  }

  /// Unregisters the existing callback for the flagKey.
  ///
  /// [flagKey] the flag key to remove the listener from
  Future<bool?> unregisterFeatureFlagListener(String? flagKey) async {
    if (flagKey == null) {
      return false;
    }

    if (!flagListeners!.containsKey(flagKey) || flagListeners![flagKey] == null) {
      return false;
    }

    flagListeners!.remove(flagKey);
    return await _channel.invokeMethod(
        'unregisterFeatureFlagListener', <String, dynamic>{'flagKey': flagKey});
  }

  /// Returns a map of all feature flags for the current user. No events are sent to LaunchDarkly.
  Future<Map<String, dynamic>> allFlags() async {
    Map<String, dynamic> allFlags =
        Map<String, dynamic>.from(await _channel.invokeMethod('allFlags'));
    return allFlags;
  }

  /// Registers a callback to be called when a flag update is processed by the
  /// SDK.
  ///
  /// [listenerId]  the id to attach the listener to
  /// [callback] the listener to attach to the listenerId
  Future<bool?> registerAllFlagsListener(
      String? listenerId, void Function(List<String>)? callback) async {
    if (listenerId == null || callback == null) {
      return false;
    }

    if (allFlagsListeners!.containsKey(listenerId)) {
      allFlagsListeners![listenerId] = callback;
      return true;
    }

    allFlagsListeners![listenerId] = callback;
    return await _channel.invokeMethod('registerAllFlagsListener',
        <String, dynamic>{'listenerId': listenerId});
  }

  /// Unregisters a callback so it will no longer be called on flag updates.
  ///
  /// [listenerId] the id to remove the listener from
  Future<bool?> unregisterAllFlagsListener(String? listenerId) async {
    if (listenerId == null) {
      return false;
    }

    if (!allFlagsListeners!.containsKey(listenerId) ||
        allFlagsListeners![listenerId] == null) {
      return false;
    }

    allFlagsListeners!.remove(listenerId);
    return await _channel.invokeMethod('unregisterAllFlagsListener',
        <String, dynamic>{'listenerId': listenerId});
  }
}
