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
  bool _shouldShowListener = false;
  LaunchdarklyFlutter launchdarklyFlutter;

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
      await launchdarklyFlutter.init('YOUR_MOBILE_KEY', 'USER_ID');
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
                  verifyFlag('FLAG_KEY');

                  try{
                    await launchdarklyFlutter.registerFeatureFlagListener('FLAG_KEY', verifyFlagListener);
                  } on PlatformException {}
                },
                child: Text('Verify'),
              ),
              SizedBox(height: 10.0,),
              Text('Should show listener: $_shouldShowListener\n'),
            ],
          ),
        ),
      ),
    );
  }

  void verifyFlag(String flagKey) async {
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

  void verifyFlagListener(String flagKey) async {
    bool shouldShowListener;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      shouldShowListener =
      await launchdarklyFlutter.boolVariation(flagKey, false);
    } on PlatformException {
      shouldShowListener = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _shouldShowListener = shouldShowListener;
    });
  }
}