part of "launchdarkly_flutter.dart";

extension _LaunchDarklyUserSerializer on LaunchDarklyUser {
  /// The method of serialization to a map.
  /// Intended to use to pass over the MethodChannel.
  Map<String, dynamic> toMap() => {
        'secondary': secondaryKey,
        'ip': ip,
        'country': country,
        'avatar': avatar,
        'email': email,
        'name': name,
        'firstName': firstName,
        'lastName': lastName,
      };
}

extension _LaunchDarklyConfigSerializer on LaunchDarklyConfig {
  /// The method of serialization to a map.
  /// Intended to use to pass over the MethodChannel.
  Map<String, dynamic> toMap() => {
        'allAttributesPrivate': allAttributesPrivate,
        'privateAttributes': privateAttributes.toList(),
      };
}
