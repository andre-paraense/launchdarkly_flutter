package com.oakam.launchdarkly_flutter;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.launchdarkly.android.FeatureFlagChangeListener;
import com.launchdarkly.android.LDClient;
import com.launchdarkly.android.LDConfig;
import com.launchdarkly.android.LDUser;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

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
  private Map<String, FeatureFlagChangeListener> listeners = new HashMap<>();

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
      ldClient.close();
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

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    if(call.method.equals("init")){

      String mobileKey = call.argument("mobileKey");

      if(mobileKey == null){
        result.error("mobileKey null", null, null);
        return;
      }

      LDConfig ldConfig = new LDConfig.Builder()
              .setMobileKey(mobileKey)
              .build();

      LDUser user = null;

      if(call.hasArgument("userKey")) {
        String userKey = call.argument("userKey");

        user = new LDUser.Builder(userKey)
                .build();
      }else {
        user = new LDUser.Builder("")
                .anonymous(true)
                .build();
      }

      ldClient = LDClient.init(activity.getApplication(), ldConfig, user, 5);

      result.success(true);
    } else if (call.method.equals("boolVariation")) {
      String flagKey = call.argument("flagKey");
      result.success(ldClient.boolVariation(flagKey,null));
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
    } else if (call.method.equals("registerFeatureFlagListener")) {

      String flagKey = call.argument("flagKey");

      FeatureFlagChangeListener listener = new FeatureFlagChangeListener() {
        @Override
        public void onFeatureFlagChange(String flagKey) {
          Map<String, String> arguments = new HashMap<>();
          arguments.put("flagKey",flagKey);

          channel.invokeMethod("callbackRegisterFeatureFlagListener",arguments);
        }
      };

      ldClient.registerFeatureFlagListener(flagKey, listener);
      listeners.put(flagKey, listener);

    } else if (call.method.equals("unregisterFeatureFlagListener")) {
      String flagKey = call.argument("flagKey");
      if (listeners.containsKey(flagKey)) {
        ldClient.unregisterFeatureFlagListener(flagKey, listeners.get(flagKey));
        listeners.remove(flagKey);
        result.success(true);
        return;
      }
      result.success(false);
    } else {
      result.notImplemented();
    }
  }

  private void setupChannel(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "launchdarkly_flutter");
    channel.setMethodCallHandler(this);
  }
}
