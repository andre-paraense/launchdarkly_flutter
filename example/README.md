# launchdarkly_flutter_example

Demonstrates how to use the launchdarkly_flutter plugin.

In this example app, replace the string `YOUR_MOBILE_KEY` with your mobile key from your [Environments](https://app.launchdarkly.com/settings#/environments) page.

## Example

You just need to instantiate the class and initiate the plugin with your mobile key and the user information, before checking the flags.

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

Replace `FLAG_KEY` with your flag key.
