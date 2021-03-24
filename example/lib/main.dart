import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launchdarkly_flutter/launchdarkly_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _shouldShow = false;
  bool _listenerRegistered = false;
  Map<String, dynamic> _allFlags = {};
  bool _listenerAllFlagsRegistered = false;
  bool _isLoggedIn = true;
  late LaunchdarklyFlutter launchdarklyFlutter;

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
      await launchdarklyFlutter.init(mobileKey, userId, custom: _customAttrs);
    } on PlatformException {}
  }

  Future<void> _onLoginToggleClick() async {
    final isLoggedIn = !_isLoggedIn;
    await launchdarklyFlutter.identify(
      isLoggedIn ? userId : null,
      custom: _customAttrs,
    );
    setState(() => _isLoggedIn = isLoggedIn);
    _verifyFlag(flagKey);
    _verifyAllFlags([]);
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: _onLoginToggleClick,
                  child: Text(_isLoggedIn ? 'Log out' : 'Log in'),
                ),
              ),
              Text('Should show: $_shouldShow\n'),
              ElevatedButton(
                onPressed: () async {
                  _verifyFlag(flagKey);
                },
                child: Text('Verify'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_listenerRegistered) {
                    try {
                      setState(() {
                        _listenerRegistered = false;
                      });
                      await launchdarklyFlutter
                          .unregisterFeatureFlagListener(flagKey);
                    } on PlatformException {
                      setState(() {
                        _listenerRegistered = true;
                      });
                    }
                  } else {
                    try {
                      setState(() {
                        _listenerRegistered = true;
                      });
                      await launchdarklyFlutter.registerFeatureFlagListener(
                          flagKey, _verifyFlag);
                    } on PlatformException {
                      setState(() {
                        _listenerRegistered = false;
                      });
                    }
                  }
                },
                child: Text(_listenerRegistered
                    ? 'Unregister listener'
                    : 'Register listener'),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  _verifyAllFlags([]);
                },
                child: Text('Verify all flags'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_listenerAllFlagsRegistered) {
                    try {
                      setState(() {
                        _listenerAllFlagsRegistered = false;
                      });
                      await launchdarklyFlutter
                          .unregisterAllFlagsListener('allFlags');
                    } on PlatformException {
                      setState(() {
                        _listenerAllFlagsRegistered = true;
                      });
                    }
                  } else {
                    try {
                      setState(() {
                        _listenerAllFlagsRegistered = true;
                      });
                      await launchdarklyFlutter.registerAllFlagsListener(
                          'allFlags', _verifyAllFlags);
                    } on PlatformException {
                      setState(() {
                        _listenerAllFlagsRegistered = false;
                      });
                    }
                  }
                },
                child: Text(_listenerAllFlagsRegistered
                    ? 'Unregister All Flags listener'
                    : 'Register All Flags listener'),
              ),
              Text('All flags: $_allFlags\n'),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyFlag(String? flagKey) async {
    bool? shouldShow;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      shouldShow = await launchdarklyFlutter.boolVariation(flagKey!, false);
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

  void _verifyAllFlags(List<String> flagKeys) async {
    Map<String, dynamic> allFlags;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      allFlags = await launchdarklyFlutter.allFlags();
    } on PlatformException {
      allFlags = {};
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _allFlags = allFlags;
    });
  }
}

const _customAttrs = {
  'string': 'value',
  'boolean': true,
  'number': 10,
};
