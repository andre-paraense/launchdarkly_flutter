import Flutter
import UIKit

import LaunchDarkly

@objc public class SwiftLaunchdarklyFlutterPlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "launchdarkly_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftLaunchdarklyFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
    if (call.method == "init") {

    } else if(call.method == "boolVariation") {

    } else if (call.method == "boolVariationFallback") {

    } else if(call.method == "stringVariation") {

    } else if(call.method == "stringVariationFallback") {

    }
  }
}
