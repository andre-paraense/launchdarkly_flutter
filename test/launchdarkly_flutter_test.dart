import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchdarkly_flutter/launchdarkly_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('launchdarkly_flutter');

  final Map<String, void Function(String)> flagListeners = {};

  final LaunchdarklyFlutter launchdarklyFlutter =
      LaunchdarklyFlutter(flagListeners: flagListeners);

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'init') {
        Map<dynamic, dynamic> args = methodCall.arguments;
        if (args['mobileKey'] == null) {
          return false;
        } else if (args['userKey'] == null) {
          return true;
        } else {
          return true;
        }
      }

      if (methodCall.method == 'boolVariation') {
        return true;
      } else if (methodCall.method == 'boolVariationFallback') {
        Map<dynamic, dynamic> args = methodCall.arguments;
        return args['fallback'];
      }

      if (methodCall.method == 'stringVariation') {
        return 'something';
      } else if (methodCall.method == 'stringVariationFallback') {
        Map<dynamic, dynamic> args = methodCall.arguments;
        return args['fallback'];
      }

      if (methodCall.method == 'registerFeatureFlagListener') {
        return true;
      }

      if (methodCall.method == 'unregisterFeatureFlagListener') {
        return true;
      }

      return launchdarklyFlutter.handlerMethodCalls(methodCall);
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('init with no mobile key', () async {
    expect(await launchdarklyFlutter.init(null, null), false);
  });

  test('init with no user', () async {
    expect(await launchdarklyFlutter.init('MOBILE_KEY', null), true);
  });

  test('init with all arguments', () async {
    expect(await launchdarklyFlutter.init('MOBILE_KEY', 'USER_ID'), true);
  });

  test('boolVariation with no fallback', () async {
    expect(await launchdarklyFlutter.boolVariation('ipPermitted', null), true);
  });

  test('boolVariation with fallback true', () async {
    expect(await launchdarklyFlutter.boolVariation('ipPermitted', true), true);
  });

  test('boolVariation with fallback false', () async {
    expect(
        await launchdarklyFlutter.boolVariation('ipPermitted', false), false);
  });

  test('stringVariation with no fallback', () async {
    expect(await launchdarklyFlutter.stringVariation('ipPermitted', null),
        'something');
  });

  test('stringVariation with fallback', () async {
    expect(await launchdarklyFlutter.stringVariation('ipPermitted', 'nothing'),
        'nothing');
  });

  test('registerFeatureFlagListener with flagKey and callback null', () async {
    String flagKey = 'flagKey';
    await launchdarklyFlutter.registerFeatureFlagListener(null, null);
    expect(flagListeners[flagKey], null);
  });

  test('registerFeatureFlagListener with callback null', () async {
    String flagKey = 'flagKey';
    await launchdarklyFlutter.registerFeatureFlagListener(flagKey, null);
    expect(flagListeners[flagKey], null);
  });

  test('registerFeatureFlagListener with flagKey null', () async {
    String flagKey = 'flagKey';
    void Function(String) callback = (flagKey) {};

    await launchdarklyFlutter.registerFeatureFlagListener(null, callback);
    expect(flagListeners[flagKey], null);
  });

  test('registerFeatureFlagListener registering flagKey with callback',
      () async {
    String flagKey = 'flagKey';
    Function(String) callback = (flagKey) {
      return flagKey;
    };

    await launchdarklyFlutter.registerFeatureFlagListener(flagKey, callback);
    expect(flagListeners[flagKey], callback);
  });

  test('unregisterFeatureFlagListener with flagKey null', () async {
    String flagKey = 'flagKey';
    Function(String) callback = (flagKey) {
      return 'callback';
    };
    await launchdarklyFlutter.registerFeatureFlagListener(flagKey, callback);
    expect(flagListeners[flagKey], callback);
    await launchdarklyFlutter.unregisterFeatureFlagListener(null);
    expect(flagListeners[flagKey], callback);
  });

  test('unregisterFeatureFlagListener flagKey', () async {
    String flagKey = 'flagKey';
    Function(String) callback = (flagKey) {
      return 'callback';
    };
    await launchdarklyFlutter.registerFeatureFlagListener(flagKey, callback);
    expect(flagListeners[flagKey], callback);
    await launchdarklyFlutter.unregisterFeatureFlagListener(flagKey);
    expect(flagListeners[flagKey], null);
  });

  test('registerFeatureFlagListener callback for non-existing method',
      () async {
    String flagKey = 'flagKey';

    Map<String, String> arguments = {};
    arguments['flagKey'] = flagKey;

    try {
      await channel.invokeMethod('non-existing-method', arguments);
      fail("exception not thrown");
    } catch (e) {
      expect(e, isInstanceOf<MissingPluginException>());
    }
  });

  test(
      'registerFeatureFlagListener callback for existing callbackRegisterFeatureFlagListener method with wrong flagKey',
      () async {
    String flagKey = 'flagKey';
    Function(String) callback = (flagKey) {
      return flagKey;
    };

    await launchdarklyFlutter.registerFeatureFlagListener(flagKey, callback);
    expect(flagListeners[flagKey], callback);

    Map<String, String> arguments = {};
    arguments['flagKey'] = 'wrong-flag-key';

    expect(
        await channel.invokeMethod(
            'callbackRegisterFeatureFlagListener', arguments),
        false);
  });

  test(
      'registerFeatureFlagListener callback for existing callbackRegisterFeatureFlagListener method with correct flagKey',
      () async {
    String flagKey = 'flagKey';
    Function(String) callback = (flagKey) {
      return flagKey;
    };

    await launchdarklyFlutter.registerFeatureFlagListener(flagKey, callback);
    expect(flagListeners[flagKey], callback);

    Map<String, String> arguments = {};
    arguments['flagKey'] = flagKey;

    expect(
        await channel.invokeMethod(
            'callbackRegisterFeatureFlagListener', arguments),
        true);
  });
}
