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
  
  private func createUser(arguments: [String:Any]) -> LDUser {
    var userKey = arguments["userKey"] as? String ?? ""
    var isAnonymous = false
    if (userKey.isEmpty) {
      userKey = UUID.init().uuidString
      isAnonymous = true
    }
    
    let userAttributes = arguments["user"] as? [String:Any] ?? [:]
    
    var user = LDUser(key: userKey)
    user.isAnonymous = isAnonymous
    user.secondary = userAttributes["secondary"] as? String
    user.country = userAttributes["country"] as? String
    user.ipAddress = userAttributes["ip"] as? String
    user.avatar = userAttributes["avatar"] as? String
    user.name = userAttributes["name"] as? String
    user.firstName = userAttributes["firstName"] as? String
    user.lastName = userAttributes["lastName"] as? String
    user.email = userAttributes["email"] as? String
    user.privateAttributes = arguments["privateAttributes"] as? [String]
    user.custom = arguments["custom"] as? [String: Any]
    
    return user
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
    let arguments = call.arguments as? [String:Any] ?? [:]
    
    if (call.method == "init") {
        
        let mobileKey = arguments["mobileKey"] as? String
        
        if (mobileKey ?? "").isEmpty {
            result(false)
            return
        }
        
        let configArgs = arguments["config"] as? [String: Any] ?? [:]
        
        var config = LDConfig(mobileKey: mobileKey ?? "")
        config.allUserAttributesPrivate = configArgs["allAttributesPrivate"] as? Bool ?? false
        config.privateUserAttributes = configArgs["privateAttributes"] as? [String]
        
        LDClient.start(config: config, user: createUser(arguments: arguments), startWaitSeconds: 5) { timedOut in
            result(true)
        }
        
    } else if (call.method == "identify") {
        LDClient.get()!.identify(user: createUser(arguments: arguments), completion: { result(true) })
    
    } else if(call.method == "boolVariation") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        result(LDClient.get()!.variation(forKey: flagKey, defaultValue: false) as Bool)

    } else if (call.method == "boolVariationFallback") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        let fallback = arguments["fallback"] as? Bool ?? false
        
        result(LDClient.get()!.variation(forKey: flagKey, defaultValue: fallback) as Bool)

    } else if(call.method == "stringVariation") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        result(LDClient.get()!.variation(forKey: flagKey, defaultValue: "") as String)

    } else if(call.method == "stringVariationFallback") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
               
        let fallback = arguments["fallback"] as? String ?? ""
               
        result(LDClient.get()!.variation(forKey: flagKey, defaultValue: fallback) as String)
        
    } else if(call.method == "allFlags") {
        
        let allFlags = LDClient.get()!.allFlags ?? [:]
               
        result(allFlags)
        
    } else if(call.method == "registerFeatureFlagListener") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        let flagObserverOwner = flagKey as LDObserverOwner

        LDClient.get()!.observe(keys: [flagKey], owner: flagObserverOwner, handler: { (changedFlags) in
            if changedFlags[flagKey] != nil {
                let flagKeyMap = ["flagKey": flagKey]
                DispatchQueue.main.async {
                  FlutterChannel.shared.channel?.invokeMethod("callbackRegisterFeatureFlagListener", arguments: flagKeyMap)
                }
            }
        })
        
        FlutterChannel.shared.listeners[flagKey] = flagObserverOwner;
        
        result(true)
    
    } else if(call.method == "unregisterFeatureFlagListener") {
        
        let flagKey = arguments["flagKey"] as? String ?? ""
        
        if (FlutterChannel.shared.listeners[flagKey] != nil) {
            LDClient.get()!.stopObserving(owner: FlutterChannel.shared.listeners[flagKey] ?? flagKey as LDObserverOwner)
            FlutterChannel.shared.listeners.removeValue(forKey: flagKey)
            result(true)
            return
        }
        
        result(false)
    } else if(call.method == "registerAllFlagsListener") {
        
        let listenerId = arguments["listenerId"] as? String ?? ""
        
        let allFlagsObserverOwner = listenerId as LDObserverOwner
        
        LDClient.get()!.observeAll(owner: allFlagsObserverOwner) { (changedFlags) in
            var allFlagsChanged = [String]();
            for (key, _) in changedFlags {
                allFlagsChanged.append(key)
            }
            let flagKeyMap = ["flagKeys": allFlagsChanged]
            DispatchQueue.main.async {
              FlutterChannel.shared.channel?.invokeMethod("callbackAllFlagsListener", arguments: flagKeyMap)
            }
        }
        
        FlutterChannel.shared.listeners[listenerId] = allFlagsObserverOwner;
        
        result(true)
    
    } else if(call.method == "unregisterAllFlagsListener") {
        
        let listenerId = arguments["listenerId"] as? String ?? ""
        
        if (FlutterChannel.shared.listeners[listenerId] != nil) {
            LDClient.get()!.stopObserving(owner: FlutterChannel.shared.listeners[listenerId] ?? listenerId as LDObserverOwner)
            FlutterChannel.shared.listeners.removeValue(forKey: listenerId)
            result(true)
            return
        }
        
        result(false)
    } else {
        result(FlutterMethodNotImplemented)
    }
  }
}
