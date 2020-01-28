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
    let arguments = call.arguments as! [String:Any]
    
    if (call.method == "init") {
        
        let mobileKey = arguments["mobileKey"] as? String
        
        if (mobileKey ?? "").isEmpty {
            result(false)
        }
        
        let config = LDConfig(mobileKey: mobileKey ?? "")
        
        let userKey = arguments["userKey"] as? String
        let userEmail = arguments["userEmail"] as? String
        
        if( (userKey ?? "").isEmpty || (userEmail ?? "").isEmpty) {
            
            LDClient.shared.startCompleteWhenFlagsReceived(config: config)
            
        }else{
            
            let user = LDUser(key: userKey, email: userEmail)
            LDClient.shared.startCompleteWhenFlagsReceived(config: config, user: user)
        }
        
        result(true)

    } else if(call.method == "boolVariation") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        result(LDClient.shared.variation(forKey: flagKey, fallback: false))

    } else if (call.method == "boolVariationFallback") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        var fallback = arguments["fallback"] as? Bool ?? false
        
        result(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as Bool)

    } else if(call.method == "stringVariation") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        result(LDClient.shared.variation(forKey: flagKey, fallback: ""))

    } else if(call.method == "stringVariationFallback") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
               
        var fallback = arguments["fallback"] as? String ?? ""
               
        result(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as String)
        
    } else {
        result(FlutterMethodNotImplemented)
    }
  }
}
