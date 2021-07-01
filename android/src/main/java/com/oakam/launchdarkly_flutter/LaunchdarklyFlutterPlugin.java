package com.oakam.launchdarkly_flutter;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.launchdarkly.sdk.LDValue;
import com.launchdarkly.sdk.android.FeatureFlagChangeListener;
import com.launchdarkly.sdk.android.LDAllFlagsListener;
import com.launchdarkly.sdk.android.LDClient;
import com.launchdarkly.sdk.android.LDConfig;
import com.launchdarkly.sdk.LDUser;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** LaunchdarklyFlutterPlugin */
public class LaunchdarklyFlutterPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {

  private MethodChannel channel;
  private Activity activity;
  private LDClient ldClient;
  private final Map<String, FeatureFlagChangeListener> listeners = new HashMap<>();
  private final Map<String, LDAllFlagsListener> allFlagsListeners = new HashMap<>();

  public LaunchdarklyFlutterPlugin() {}

  public LaunchdarklyFlutterPlugin(Activity activity){
    this.activity = activity;
  }

  public static void registerWith(Registrar registrar) {
    final LaunchdarklyFlutterPlugin launchdarklyFlutterPlugin = new LaunchdarklyFlutterPlugin(registrar.activity());
    launchdarklyFlutterPlugin.setupChannel(registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    setupChannel(flutterPluginBinding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;

    try {
      if (ldClient != null){
        ldClient.close();
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }

  private LDUser createUser(@NonNull MethodCall call) {
    LDUser.Builder userBuilder;

    if (call.hasArgument("userKey")) {
      String userKey = call.argument("userKey");
      userBuilder = new LDUser.Builder(userKey).anonymous(false);
    } else {
      userBuilder = new LDUser.Builder(UUID.randomUUID().toString()).anonymous(true);
    }

    Map<String, Object> custom = call.argument("custom");
    if (custom != null) {
      for (String key : custom.keySet()) {
        final Object value = custom.get(key);
        if (value instanceof String) {
          userBuilder.custom(key, (String) value);
        } else if (value instanceof Integer) {
          userBuilder.custom(key, (Integer) value);
        } else if (value instanceof Double) {
          userBuilder.custom(key, (Double) value);
       } else if (value instanceof Boolean) {
          userBuilder.custom(key, (Boolean) value);
        }
      }
    }

    return userBuilder.build();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    if(call.method.equals("init")){

      String mobileKey = call.argument("mobileKey");

      if(mobileKey == null){
        result.error("mobileKey null", null, null);
        return;
      }

      LDConfig ldConfig = new LDConfig.Builder()
              .mobileKey(mobileKey)
              .build();

      ldClient = LDClient.init(activity.getApplication(), ldConfig, createUser(call), 5);

      result.success(true);
    } else if (call.method.equals("identify")) {
      ldClient.identify(createUser(call));
      result.success(true);
    } else if (call.method.equals("boolVariation")) {
      String flagKey = call.argument("flagKey");
      result.success(ldClient.boolVariation(flagKey,false));
    } else if (call.method.equals("boolVariationFallback")) {
      String flagKey = call.argument("flagKey");
      Boolean fallback = call.argument("fallback");
      result.success(ldClient.boolVariation(flagKey,fallback));
    } else if (call.method.equals("stringVariation")) {
      String flagKey = call.argument("flagKey");
      result.success(ldClient.stringVariation(flagKey,null));
    } else if (call.method.equals("stringVariationFallback")) {
      String flagKey = call.argument("flagKey");
      String fallback = call.argument("fallback");
      result.success(ldClient.stringVariation(flagKey,fallback));
    } else if (call.method.equals("allFlags")) {
      Map<String, LDValue> flagValues = ldClient.allFlags();
      Map<String, Object> flagPrimitiveValues = new HashMap<>();
      for (Map.Entry<String, LDValue> flag : flagValues.entrySet()) {
        switch (flag.getValue().getType()) {
          case NULL: // Do something with flag missing value
            flagPrimitiveValues.put(flag.getKey(), null);
            break;
          case BOOLEAN: // Do something with boolean flag
            flagPrimitiveValues.put(flag.getKey(), flag.getValue().booleanValue());
            break;
          case NUMBER:// Do something with numeric flag
            flagPrimitiveValues.put(flag.getKey(), flag.getValue().floatValue());
            break;
          case STRING: // Do something with string flag
            flagPrimitiveValues.put(flag.getKey(), flag.getValue().stringValue());
            break;
          case ARRAY: // Do something with array flag
            break;
          case OBJECT: // Do something with object flag
            break;
        }
      }
      result.success(flagPrimitiveValues);
    } else if (call.method.equals("registerFeatureFlagListener")) {

      String flagKey = call.argument("flagKey");

      FeatureFlagChangeListener listener = new FeatureFlagChangeListener() {
        @Override
        public void onFeatureFlagChange(final String flagKey) {
          new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
              Map<String, String> arguments = new HashMap<>();
              arguments.put("flagKey",flagKey);
              try{
                channel.invokeMethod("callbackRegisterFeatureFlagListener",arguments);
              }catch (Exception e){
                Log.e("FeatureFlagsListener", e.getMessage());
              }
            }
          });
        }
      };

      ldClient.registerFeatureFlagListener(flagKey, listener);
      listeners.put(flagKey, listener);
      result.success(true);
    } else if (call.method.equals("unregisterFeatureFlagListener")) {
      String flagKey = call.argument("flagKey");
      if (listeners.containsKey(flagKey)) {
        ldClient.unregisterFeatureFlagListener(flagKey, listeners.get(flagKey));
        listeners.remove(flagKey);
        result.success(true);
        return;
      }
      result.success(false);
    } else if (call.method.equals("registerAllFlagsListener")) {

      String listenerId = call.argument("listenerId");

      LDAllFlagsListener listener = new LDAllFlagsListener() {
        @Override
        public void onChange(final List<String> flagKeys) {
          new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
              Map<String, List<String>> arguments = new HashMap<>();
              arguments.put("flagKeys",flagKeys);

              try{
                channel.invokeMethod("callbackAllFlagsListener",arguments);
              }catch (Exception e){
                Log.e("callAllFlagsListener", e.getMessage());
              }
            }
          });
        }
      };

      ldClient.registerAllFlagsListener(listener);
      allFlagsListeners.put(listenerId, listener);
      result.success(true);
    }  else if (call.method.equals("unregisterAllFlagsListener")) {
      String listenerId = call.argument("listenerId");
      if (allFlagsListeners.containsKey(listenerId)) {
        ldClient.unregisterAllFlagsListener(allFlagsListeners.get(listenerId));
        listeners.remove(listenerId);
        result.success(true);
        return;
      }
      result.success(false);
    }else {
      result.notImplemented();
    }
  }

  private void setupChannel(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "launchdarkly_flutter");
    channel.setMethodCallHandler(this);
  }
}
