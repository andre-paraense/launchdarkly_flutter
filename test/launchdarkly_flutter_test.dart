import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchdarkly_flutter/launchdarkly_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('launchdarkly_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if(methodCall.method == 'boolVariation'){
        return true;
      }else if(methodCall.method == 'boolVariationFallback'){
        return false;
      }
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  LaunchdarklyFlutter launchdarklyFlutter = LaunchdarklyFlutter();

  test('boolVariation', () async {
    expect(await launchdarklyFlutter.boolVariation('ipPermitted', true), false);
    expect(await launchdarklyFlutter.boolVariation('ipPermitted', null), true);
  });
}
