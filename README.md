# LaunchDarkly Client-side SDK for Flutter

![](https://github.com/andre-paraense/launchdarkly_flutter/workflows/CI/badge.svg) [![codecov](https://codecov.io/gh/andre-paraense/launchdarkly_flutter/branch/master/graph/badge.svg)](https://codecov.io/gh/andre-paraense/launchdarkly_flutter) [![License: MIT](https://img.shields.io/badge/License-LGPL3.0-green.svg)](https://opensource.org/licenses/LGPL-3.0) [![Pub](https://img.shields.io/pub/v/launchdarkly_flutter.svg)](https://pub.dartlang.org/packages/launchdarkly_flutter)

This is a LaunchDarkly SDK for Flutter.

This is a work in progress and there are still some features that have not been addressed. You are welcome to [contribute](CONTRIBUTING.md).

## Getting started

Check LaunchDarkly's [documentation](https://docs.launchdarkly.com) for in-depth instructions on configuring and using LaunchDarkly.

To use this plugin, add `launchdarkly_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

Import `package:launchdarkly_flutter/launchdarkly_flutter.dart`, instantiate `LaunchdarklyFlutter` and initiate the plugin with your mobile key from your [Environments](https://app.launchdarkly.com/settings#/environments) page.

### Android integration

Because LaunchDarkly Android's SDK (`com.launchdarkly:launchdarkly-android-client-sdk:3.0.0`) has the label attribute value set in its `<application>` element, there is a need to override it with your app's own label, if there is one (you will likely have one! :)).
Hence, you will need to add `tools:replace="android:label"` to the `<application>` element in your `AndroidManifest.xml`.

```xml
<application
        tools:replace="android:label"
        android:name="io.flutter.app.FlutterApplication"
        android:label="YOUR_LABEL"
        android:icon="@mipmap/ic_launcher">
```

You will probably need to insert the `tools` namespace as well, on the top of your `AndroidManifest.xml` file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="YOUR.PACKAGE.HERE">
```

## Example

There is an [example](./example) app that demonstrates how to use the plugin.

You need to instantiate the class and initiate the plugin with your mobile key and the user information, before checking the flags.

```dart
// Platform messages are asynchronous, so we initialize in an async method.
LaunchdarklyFlutter launchdarklyFlutter = LaunchdarklyFlutter();

try {
  await launchdarklyFlutter.init('YOUR_MOBILE_KEY', 'USER_ID');
} on PlatformException {}
```
Be sure to use a mobile key from your [Environments](https://app.launchdarkly.com/settings#/environments) page. Never embed a server-side SDK key into a mobile application. Check LaunchDarkly's [documentation](https://docs.launchdarkly.com) for in-depth instructions on configuring and using LaunchDarkly.

Optionally, you can choose to pass additional configuration parameters like:
```dart
await launchdarklyFlutter.init('YOUR_MOBILE_KEY', 'USER_ID', config: LaunchDarklyConfig(allAttributesPrivate: false,));
```

Give some time for the initialization process to fetch new flags values (or risk getting the defaults right away), and check them:

```dart
// Platform messages are asynchronous, so we fetch flags in an async method.
bool shouldShowButton;
// Platform messages may fail, so we use a try/catch PlatformException.
try {
  shouldShowButton = await launchdarklyFlutter.boolVariation('FLAG_KEY', false);
} on PlatformException {
  shouldShowButton = false;
}
```

### Built-in user attributes

LaunchDarkly includes a set of built-in attributes for users, like `key`, `firstName`, `lastName`, `email`.
For details, please refer to [Understanding user attributes](https://docs.launchdarkly.com/home/users/attributes#understanding-user-attributes).

The built-in user attributes can be set via parameter `user` of `LaunchDarklyUser` type:
```dart
final user = LaunchDarklyUser(
  email: 'example@example.com',
);
await launchdarklyFlutter.init(mobileKey, userId, user: user);
```

### Custom attributes

In addtion to the built-in user attributes, you can pass your own custom attributes.

```dart
final attrs = {
  'string': 'value',
  'boolean': true,
  'number': 10,
};
await launchdarklyFlutter.init(mobileKey, userId, custom: attrs);
```

Your custom attributes map should have keys of type `String` and values of type `String | bool | number` (for deleting an attribute remove the key or set value to `null`).

### Private attributes

You may not want to send all attributes back to LaunchDarkly due to the security or data protection requirements of your organization.
LaunchDarkly's private user attributes feature lets you choose which attributes get sent back to LaunchDarkly without sacrificing the ability to target user segments.

- You can mark all attributes private globally in the `LaunchDarklyConfig` configuration object.
- You can mark specific attributes private by name globally in the `LaunchDarklyConfig` configuration object.
- You can mark specific attributes private by name for individual users when you call `init` / `identify` (see below).

```dart
final user = LaunchDarklyUser(
  privateEmail: 'example@example.com',
);
final privateAttrs = {
  'string': 'value',
  'boolean': true,
  'number': 10,
};
await launchdarklyFlutter.init(mobileKey, userId, user: user, privateCustom: privateAttrs);
```

More about private user attributes can be found [here](https://docs.launchdarkly.com/home/users/attributes#creating-private-user-attributes).

### Changing the User Context

If your app is used by multiple users on a single device, you may want to change users and have separate flag settings for each user.

You can use the identify method to switch user contexts:

```dart
await launchdarklyFlutter.identify(userId, user: user, custom: custom, privateCustom: privateCustom);
```

## Not supported yet

Check LaunchDarkly's [documentation](https://docs.launchdarkly.com) for more information on the features not yet supported. We are slowly and iteratively adding more features as we use them in our own projects. You are welcome to [contribute](CONTRIBUTING.md).

## Contributing

We encourage pull requests and other contributions from the community. Check out our [contributing guidelines](CONTRIBUTING.md) for instructions on how to contribute to this SDK.

## About LaunchDarkly

* LaunchDarkly is a continuous delivery platform that provides feature flags as a service and allows developers to iterate quickly and safely. We allow you to easily flag your features and manage them from the LaunchDarkly dashboard.  With LaunchDarkly, you can:
    * Roll out a new feature to a subset of your users (like a group of users who opt-in to a beta tester group), gathering feedback and bug reports from real-world use cases.
    * Gradually roll out a feature to an increasing percentage of users, and track the effect that the feature has on key metrics (for instance, how likely is a user to complete a purchase if they have feature A versus feature B?).
    * Turn off a feature that you realize is causing performance problems in production, without needing to re-deploy, or even restart the application with a changed configuration file.
    * Grant access to certain features based on user attributes, like payment plan (eg: users on the ‘gold’ plan get access to more features than users in the ‘silver’ plan). Disable parts of your application to facilitate maintenance, without taking everything offline.
* LaunchDarkly provides feature flag SDKs for a wide variety of languages and technologies. Check out [our documentation](https://docs.launchdarkly.com/docs) for a complete list.
* Explore LaunchDarkly
    * [launchdarkly.com](https://www.launchdarkly.com/ "LaunchDarkly Main Website") for more information
    * [docs.launchdarkly.com](https://docs.launchdarkly.com/  "LaunchDarkly Documentation") for our documentation and SDK reference guides
    * [apidocs.launchdarkly.com](https://apidocs.launchdarkly.com/  "LaunchDarkly API Documentation") for our API documentation
    * [blog.launchdarkly.com](https://blog.launchdarkly.com/  "LaunchDarkly Blog Documentation") for the latest product updates
    * [Feature Flagging Guide](https://github.com/launchdarkly/featureflags/  "Feature Flagging Guide") for best practices and strategies
