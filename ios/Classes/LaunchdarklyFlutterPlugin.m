#import "LaunchdarklyFlutterPlugin.h"
#if __has_include(<launchdarkly_flutter/launchdarkly_flutter-Swift.h>)
#import <launchdarkly_flutter/launchdarkly_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "launchdarkly_flutter-Swift.h"
#endif

@implementation LaunchdarklyFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLaunchdarklyFlutterPlugin registerWithRegistrar:registrar];
}
@end
