import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:launchdarkly_flutter/launchdarkly_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _shouldShow = false;
  LaunchdarklyFlutter launchdarklyFlutter;

  String mobileKey = 'YOUR_MOBILE_KEY';
  String userId = 'USER_ID';
  String flagKey = 'FLAG_KEY';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.

    launchdarklyFlutter = LaunchdarklyFlutter();

    try {
      await launchdarklyFlutter.init(mobileKey, userId);
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('LaunchDarkly Plugin'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Should show: $_shouldShow\n'),
              RaisedButton(
                onPressed: () async {
                  _verifyFlag(flagKey);
                },
                child: Text('Verify'),
              ),
              RaisedButton(
                onPressed: () async {
                  try{
                    await launchdarklyFlutter.registerFeatureFlagListener(flagKey, _verifyFlag);
                  } on PlatformException {}
                },
                child: Text('Register listener'),
              ),
              RaisedButton(
                onPressed: () async {
                  try{
                    await launchdarklyFlutter.unregisterFeatureFlagListener(flagKey);
                  } on PlatformException {}
                },
                child: Text('Unregister listener'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyFlag(String flagKey) async {
    bool shouldShow;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      shouldShow =
          await launchdarklyFlutter.boolVariation(flagKey, false);
    } on PlatformException {
      shouldShow = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _shouldShow = shouldShow;
    });
  }
}