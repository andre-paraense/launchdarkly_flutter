import Flutter
import UIKit

import LaunchDarkly

@objc public class SwiftLaunchdarklyFlutterPlugin: NSObject, FlutterPlugin {
    
  class FlutterChannel: NSObject {
    static let shared: FlutterChannel = FlutterChannel()
    var channel: FlutterMethodChannel?
    var listeners = [String: LDObserverOwner]()
    
    private override init() {}
  }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "launchdarkly_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftLaunchdarklyFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    FlutterChannel.shared.channel = channel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
    let arguments = call.arguments as? [String:Any] ?? [:]
    
    if (call.method == "init") {
        
        let mobileKey = arguments["mobileKey"] as? String
        
        if (mobileKey ?? "").isEmpty {
            result(false)
            return
        }
        
        let config = LDConfig(mobileKey: mobileKey ?? "")
        
        let userKey = arguments["userKey"] as? String
        
        if( (userKey ?? "").isEmpty ) {
            
            LDClient.shared.startCompleteWhenFlagsReceived(config: config)
            
        }else{
            
            let user = LDUser(key: userKey)
            LDClient.shared.startCompleteWhenFlagsReceived(config: config, user: user)
        }
        
        result(true)
    } else if(call.method == "boolVariation") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        result(LDClient.shared.variation(forKey: flagKey, fallback: false))

    } else if (call.method == "boolVariationFallback") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        let fallback = arguments["fallback"] as? Bool ?? false
        
        result(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as Bool)

    } else if(call.method == "stringVariation") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        result(LDClient.shared.variation(forKey: flagKey, fallback: ""))

    } else if(call.method == "stringVariationFallback") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
               
        let fallback = arguments["fallback"] as? String ?? ""
               
        result(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as String)
        
    } else if(call.method == "allFlags") {
        
        let allFlags = LDClient.shared.allFlagValues ?? [:]
               
        result(allFlags)
        
    }else if(call.method == "registerFeatureFlagListener") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        let flagObserverOwner = flagKey as LDObserverOwner

        LDClient.shared.observe(keys: [flagKey], owner: flagObserverOwner, handler: { (changedFlags) in
            if changedFlags[flagKey] != nil {
                let flagKeyMap = ["flagKey": flagKey]
                FlutterChannel.shared.channel?.invokeMethod("callbackRegisterFeatureFlagListener", arguments: flagKeyMap)
            }
        })
        
        FlutterChannel.shared.listeners[flagKey] = flagObserverOwner;
        
        result(true)
    
    } else if(call.method == "unregisterFeatureFlagListener") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        if (FlutterChannel.shared.listeners[flagKey] != nil) {
            LDClient.shared.stopObserving(owner: FlutterChannel.shared.listeners[flagKey] ?? flagKey as LDObserverOwner)
            FlutterChannel.shared.listeners.removeValue(forKey: flagKey)
            result(true)
            return
        }
        
        result(false)
    } else {
        result(FlutterMethodNotImplemented)
    }
  }
}
