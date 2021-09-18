/// This class exposes advanced configuration options for LaunchDarkly client.
class LaunchDarklyConfig {
  /// Specifies that user attributes (other than the key) should be hidden from LaunchDarkly.
  /// If this is set, all user attribute values will be private.
  final bool allAttributesPrivate;
  /// Marks a set of attributes private. Any users sent to LaunchDarkly with this configuration active will have attributes with these names removed.
  /// This can also be specified on a per-user basis, please refer to [LaunchDarklyUser].
  final Set<String> privateAttributes;

  /// Constructor for creating a LaunchDarkly config.
  /// All parameters are optional.
  const LaunchDarklyConfig({
    this.allAttributesPrivate = false,
    this.privateAttributes = const {},
  });
}