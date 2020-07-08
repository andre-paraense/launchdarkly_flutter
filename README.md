# LaunchDarkly Client-side SDK for Flutter

![](https://github.com/andre-paraense/launchdarkly_flutter/workflows/CI/badge.svg) [![codecov](https://codecov.io/gh/andre-paraense/launchdarkly_flutter/branch/master/graph/badge.svg)](https://codecov.io/gh/andre-paraense/launchdarkly_flutter) [![License: MIT](https://img.shields.io/badge/License-LGPL3.0-green.svg)](https://opensource.org/licenses/LGPL-3.0) [![Pub](https://img.shields.io/pub/v/launchdarkly_flutter.svg)](https://pub.dartlang.org/packages/launchdarkly_flutter)

This is a LaunchDarkly SDK for Flutter.

This is a work in progress and there are still some features that have not been addressed. You are welcome to [contribute](CONTRIBUTING.md).

## Supported versions

This SDK is compatible with Flutter 1.17 and Xcode 11 and is tested in Android 28 and iOS 13. Earlier versions of this SDK are compatible with prior versions of Flutter, Android, and iOS.

## Getting started

Check LaunchDarkly's [documentation](https://docs.launchdarkly.com) for in-depth instructions on configuring and using LaunchDarkly.

To use this plugin, add `launchdarkly_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

Import `package:launchdarkly_flutter/launchdarkly_flutter.dart`, instantiate `LaunchdarklyFlutter` and initiate the plugin with your mobile key from your [Environments](https://app.launchdarkly.com/settings#/environments) page.

### Android integration

Because LaunchDarkly Android's SDK (`com.launchdarkly:launchdarkly-android-client-sdk:2.11.0`) has the label attribute value set in its `<application>` element, there is a need to override it with your app's own label, if there is one (you will likely have one! :)).
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

### Custom attributes

You can pass custom attributes using `custom` argument in `init` method, e.g.:

```dart
final customAttrs = {
  'string': 'value',
  'boolean': true,
  'number': 10,
};
await launchdarklyFlutter.init(mobileKey, userId, custom: customAttrs);
```

Your custom attributes map should have keys of type `String` and values of type `String | bool | number` (for deleting an attribute remove the key or set value to `null`).

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
