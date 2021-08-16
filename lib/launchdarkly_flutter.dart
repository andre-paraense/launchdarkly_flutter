import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class LaunchDarklyConfig {
  final bool allAttributesPrivate;
  final Set<String> privateAttributes;

  const LaunchDarklyConfig({
    this.allAttributesPrivate = false,
    this.privateAttributes = const {},
  });

  Map<String, dynamic> toMap() => {
        'allAttributesPrivate': allAttributesPrivate,
        'privateAttributes': privateAttributes.toList(),
      };
}

/// A collection of attributes that can affect flag evaluation, usually corresponding to a user of your application.
///
/// If you want to avoid sending personal information back to LaunchDarkly but keep the ability to target, you can configure those attributes as private.
/// Use `private`-prefixed counterparts for this purpose.
class LaunchDarklyUser {
  /// Sets the secondary key for a user. This affects feature flag targeting as follows:
  /// if you have chosen to bucket users by a specific attribute,
  /// he secondary key (if set) is used to further distinguish between users who are otherwise identical according to that attribute.
  final String? secondaryKey;

  /// Sets the IP for a user.
  final String? ip;

  /// Set the country for a user.
  final String? country;

  /// Sets the user's avatar.
  final String? avatar;

  /// Sets the user's e-mail address.
  final String? email;

  /// Sets the user's full name.
  final String? name;

  /// Sets the user's first name.
  final String? firstName;

  /// Sets the user's last name.
  final String? lastName;

  final List<String> privateAttributes;

  LaunchDarklyUser({
    String? secondaryKey,
    String? privateSecondaryKey,
    String? ip,
    String? privateIp,
    String? country,
    String? privateCountry,
    String? avatar,
    String? privateAvatar,
    String? email,
    String? privateEmail,
    String? name,
    String? privateName,
    String? firstName,
    String? privateFirstName,
    String? lastName,
    String? privateLastName,
  })  : this.secondaryKey = privateSecondaryKey ?? secondaryKey,
        this.ip = privateIp ?? ip,
        this.country = privateCountry ?? country,
        this.avatar = privateAvatar ?? avatar,
        this.email = privateEmail ?? email,
        this.name = privateName ?? name,
        this.firstName = privateFirstName ?? firstName,
        this.lastName = privateLastName ?? lastName,
        this.privateAttributes = [
          if (privateSecondaryKey != null) 'secondaryKey',
          if (privateIp != null) 'ip',
          if (privateCountry != null) 'country',
          if (privateAvatar != null) 'avatar',
          if (privateEmail != null) 'email',
          if (privateName != null) 'name',
          if (privateFirstName != null) 'firstName',
          if (privateLastName != null) 'lastName',
        ];

  Map<String, dynamic> toMap() => {
        'secondaryKey': secondaryKey,
        'ip': ip,
        'country': country,
        'avatar': avatar,
        'email': email,
        'name': name,
        'firstName': firstName,
        'lastName': lastName,
      };
}

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
  /// Additional configuration can be set via the optional [config].
  /// [userKey] is the user id considered by LaunchDarkly for feature flag targeting and rollouts.
  /// The userKey should also uniquely identify each user. You can use a primary key, an e-mail address,
  /// or a hash, as long as the same user always has the same key. We recommend using a hash if possible.
  /// You can also distinguish logged-in users from anonymous users in the SDK by leaving the userKey parameter null.
  /// You can pass built-in user attributes as [LaunchDarklyUser] in [user].
  /// You can pass custom attributes and private custom attributes in [custom] and [privateCustom] maps accordingly.
  /// Please note private attributes take precedence over non-private ones.
  Future<bool?> init(
    String? mobileKey,
    String? userKey, {
    LaunchDarklyConfig? config,
    LaunchDarklyUser? user,
    Map<String, dynamic>? custom,
    Map<String, dynamic>? privateCustom,
  }) async {
    if (userKey == null) {
      return await _channel.invokeMethod('init', <String, dynamic>{
        'mobileKey': mobileKey,
        'config': config?.toMap(),
        'custom': {
          if (custom != null) ...custom,
          if (privateCustom != null) ...privateCustom,
        },
        'privateAttributes': privateCustom?.keys.toList(),
      });
    } else {
      return await _channel.invokeMethod('init', <String, dynamic>{
        'mobileKey': mobileKey,
        'userKey': userKey,
        'user': user?.toMap(),
        'config': config?.toMap(),
        'custom': {
          if (custom != null) ...custom,
          if (privateCustom != null) ...privateCustom,
        },
        'privateAttributes': [
          if (user != null) ...user.privateAttributes,
          if (privateCustom != null) ...privateCustom.keys,
        ],
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
  /// You can pass built-in user attributes as [LaunchDarklyUser] in [user].
  /// You can pass custom attributes and private custom attributes in [custom] and [privateCustom] maps accordingly.
  /// Please note private attributes take precedence over non-private ones.
  Future<bool?> identify(
    String? userKey, {
    LaunchDarklyUser? user,
    Map<String, dynamic>? custom,
    Map<String, dynamic>? privateCustom,
  }) =>
      _channel.invokeMethod('identify', <String, dynamic>{
        'userKey': userKey,
        'user': user?.toMap(),
        'custom': {
          if (custom != null) ...custom,
          if (privateCustom != null) ...privateCustom,
        },
        'privateAttributes': [
          if (user != null) ...user.privateAttributes,
          if (privateCustom != null) ...privateCustom.keys,
        ],
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

    if (!flagListeners!.containsKey(flagKey) ||
        flagListeners![flagKey] == null) {
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
