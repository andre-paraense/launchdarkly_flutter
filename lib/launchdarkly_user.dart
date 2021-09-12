/// A collection of attributes that can affect flag evaluation, usually corresponding to a user of your application.
///
/// If you want to avoid sending personal information back to LaunchDarkly but keep the ability to target user segments, you can configure those attributes as private.
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

  /// Constructor for creating a LaunchDarkly user.
  /// All parameters are optional.
  /// Use `private`-prefixed parameters if you want to avoid sending this paramater back to LaunchDarkly.
  /// Private parameters take precedence over public parameters.
  /// If both specified, public ones will be ignored.
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
          if (privateSecondaryKey != null) 'secondary',
          if (privateIp != null) 'ip',
          if (privateCountry != null) 'country',
          if (privateAvatar != null) 'avatar',
          if (privateEmail != null) 'email',
          if (privateName != null) 'name',
          if (privateFirstName != null) 'firstName',
          if (privateLastName != null) 'lastName',
        ];
}